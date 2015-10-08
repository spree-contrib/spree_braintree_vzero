require 'braintree'
module Spree
  class Gateway::BraintreeVzero < Gateway
    preference :merchant_id, :string
    preference :public_key, :string
    preference :private_key, :string
    preference :server, :string, default: :sandbox
    preference :'3dsecure', :boolean_select, default: false
    preference :pass_billing_and_shipping_address, :boolean_select, default: false
    preference :advanced_fraud_tools, :boolean_select, default: false
    preference :store_payments_in_vault, :select, default: -> { {values: [:do_not_store, :store_only_on_success, :store_all]} }
    preference :descriptor_name, :string
    preference :dropin_container, :string, default: 'payment-form'
    preference :dropin_checkout_form_id, :string, default: 'checkout_form_payment'
    preference :dropin_error_messages_container_id, :string, default: 'content'

    attr_reader :utils

    def self.current
      super
    end

    def payment_profiles_supported?
      false
    end

    def provider_class
      Braintree
    end

    def provider
      Braintree::Configuration.environment = preferred_server.present? ? preferred_server.to_sym : :sandbox
      Braintree::Configuration.merchant_id = preferred_merchant_id
      Braintree::Configuration.public_key = preferred_public_key
      Braintree::Configuration.private_key = preferred_private_key
      Braintree
    end

    def method_type
      'braintree_vzero'
    end

    def client_token(order = nil, user = nil)
      braintree_user = Gateway::BraintreeVzero::User.new(provider, user, order).user
      braintree_user ? provider::ClientToken.generate(customer_id: user.id) : provider::ClientToken.generate
    end

    def purchase(identifier_hash, order, device_data = nil)
      @utils = Utils.new(self, order)
      data = {}
      if preferred_pass_billing_and_shipping_address
        data.merge!(@utils.get_address('shipping'))
        data.merge!(@utils.get_address('billing')) unless order.shipping_address.same_as?(order.billing_address)
      end
      if preferred_advanced_fraud_tools
        data.merge!(device_data: device_data)
      end
      data.merge!(@utils.get_customer)
      data.merge!(@utils.order_data(identifier_hash))
      data.merge!(
        descriptor: { name: preferred_descriptor_name.to_s.gsub('/', '*') },
        options: {
          submit_for_settlement: auto_capture?,
          add_billing_address_to_payment_method: preferred_pass_billing_and_shipping_address ? true : false,
          three_d_secure: {
            required: preferred_3dsecure
          }
        }.merge!(@utils.payment_in_vault)
      )

      sale(data, order)
    end

    def admin_purchase(token, order, amount)
      @utils = BraintreeUtils.new(self, order)
      data = { amount: amount, payment_method_token: token }

      data.merge!(
        options: {
          submit_for_settlement: auto_capture?
        }.merge!(@utils.payment_in_vault)
      )

      sale(data, order)
    end

    def complete_order(order, result, payment_method)
      return false unless result.transaction
      @utils = Utils.new(self, order)
      payment = order.payments.create!(
        source: Spree::BraintreeCheckout.create!(transaction_id: result.transaction.id, state: result.transaction.status),
        amount: order.total,
        payment_method: payment_method,
        state: @utils.map_payment_status(result.transaction.status),
        response_code: result.transaction.id
      )
      payment.save!
      order.update_attributes(completed_at: Time.zone.now, state: :complete)
      order.finalize!
      order.update!
    end

    def settle(amount, checkout, gateway_options)
      result = provider::Transaction.submit_for_settlement(checkout.transaction_id, amount / 100.0)
      checkout.update_attribute(:state, result.transaction.status)
      result
    end

    def void(transaction_id, _data)
      result = provider::Transaction.void(transaction_id)

      if result.success?
        Spree::BraintreeCheckout.find_by(transaction_id: transaction_id).update(state: 'voided')
      end

      result
    end

    def credit(_credit_cents, transaction_id, _options)
      provider::Transaction.refund(transaction_id)
    end

    def customer_payment_methods(order)
      @utils = BraintreeUtils.new(self, order)
      @utils.customer_payment_methods
    end

    private

    def sale(data, order)
      result = provider::Transaction.sale(data)

      if result.success?
        order.shipping_address.update_attribute(:braintree_id, result.transaction.shipping_details.id)
        if order.shipping_address.same_as?(order.billing_address)
          order.billing_address.update_attribute(:braintree_id, result.transaction.shipping_details.id)
        else
          order.billing_address.update_attribute(:braintree_id, result.transaction.billing_details.id)
        end
      else
        result.errors.each { |e| order.errors.add(:base, I18n.t(e.message), scope: 'braintree.error') }
        if result.errors.size == 0 && result.transaction.try(:gateway_rejection_reason)
          order.errors.add(:base, I18n.t(result.transaction.gateway_rejection_reason, scope: 'braintree.error'))
        end
      end

      result
    end

  end
end
