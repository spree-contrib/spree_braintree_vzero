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
    preference :submit_for_settlement, :boolean_select, default: false

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

    def auto_capture?
      true
    end

    def method_type
      'braintree_vzero'
    end

    def client_token(order = nil, user = nil)
      braintree_user = BraintreeUser.new(provider, user, order).user
      braintree_user ? provider::ClientToken.generate(customer_id: user.id) : provider::ClientToken.generate
    end

    def purchase(nonce, order, device_data = nil)
      @utils = BraintreeUtils.new(self, order)
      data = {}
      if preferred_pass_billing_and_shipping_address
        data.merge!(billing: @utils.address_data('billing'))
        data.merge!(shipping: @utils.address_data('shipping'))
      end
      if preferred_advanced_fraud_tools
        data.merge!(device_data: device_data)
      end
      data.merge!(@utils.get_customer)
      data.merge!(@utils.order_data(nonce))
      data.merge!(
        options: {
          submit_for_settlement: preferred_submit_for_settlement,
          add_billing_address_to_payment_method: preferred_pass_billing_and_shipping_address ? true : false,
          three_d_secure: {
            required: preferred_3dsecure
          }
        }.merge!(@utils.payment_in_vault)
      )

      result = provider::Transaction.sale(data)

      unless result.success?
        result.errors.each { |e| order.errors.add(:base, I18n.t(e.message), scope: 'braintree.error') }
        if result.errors.size == 0 && result.transaction.try(:gateway_rejection_reason)
          order.errors.add(:base, I18n.t(result.transaction.gateway_rejection_reason, scope: 'braintree.error'))
        end
      end

      result
    end

    def complete_order(order, result, payment_method)
      return false unless result.transaction
      @utils = BraintreeUtils.new(self, order)
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

    def capture(amount, response_code, gateway_options)
      checkout = Spree::BraintreeCheckout.find_by_transaction_id(response_code)
      begin
        result = provider::Transaction.submit_for_settlement(response_code, amount / 100)
      ensure
        checkout.update_attribute(:state, result.transaction.status)
      end
      result
    end

    def void(transaction_id, _data)
      result = provider::Transaction.void(transaction_id)

      if result.success?
        Spree::BraintreeCheckout.find_by(transaction_id: transaction_id).update(state: 'voided')
      end

      result
    end

  end
end
