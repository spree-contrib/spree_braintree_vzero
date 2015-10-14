require 'braintree'

module Spree
  class Gateway::BraintreeVzeroBase < Gateway
    preference :merchant_id, :string
    preference :public_key, :string
    preference :private_key, :string
    preference :server, :string, default: :sandbox
    preference :'3dsecure', :boolean_select, default: false
    preference :pass_billing_and_shipping_address, :boolean_select, default: false
    preference :advanced_fraud_tools, :boolean_select, default: false
    preference :store_payments_in_vault, :select, default: -> { { values: [:do_not_store, :store_only_on_success, :store_all] } }
    preference :descriptor_name, :string

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
      braintree_user = Gateway::BraintreeVzeroBase::User.new(provider, user, order).user
      braintree_user ? provider::ClientToken.generate(customer_id: user.id) : provider::ClientToken.generate
    end

    def purchase(identifier_hash, order, device_data = nil)
      @utils = Utils.new(self, order)

      data = set_basic_purchase_data(identifier_hash, order, @utils)
      data.merge!(device_data: device_data) if preferred_advanced_fraud_tools
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
      @utils = Utils.new(self, order)
      data = { amount: amount, payment_method_token: token }

      data.merge!(
        options: {
          submit_for_settlement: auto_capture?
        }.merge!(@utils.payment_in_vault)
      )

      sale(data, order)
    end

    def complete_order(order, result, payment_method)
      return false unless (transaction = result.transaction)

      @utils = Utils.new(self, order)
      payment = order.payments.create!(
        source: Spree::BraintreeCheckout.create!(transaction_id: transaction.id,
                                                 state: transaction.status),
        amount: order.total,
        payment_method: payment_method,
        state: @utils.map_payment_status(transaction.status),
        response_code: transaction.id
      )

      payment.save!
      order.update_attributes(completed_at: Time.zone.now, state: :complete)
      order.finalize!
      order.update!
    end

    def settle(amount, checkout, gateway_options)
      result = Transaction.new(provider, checkout.transaction_id).submit_for_settlement(amount / 100.0)
      checkout.update_attribute(:state, result.transaction.status)
      result
    end

    def void(transaction_id, _data)
      result = Transaction.new(provider, transaction_id).void

      if result.success?
        Spree::BraintreeCheckout.find_by(transaction_id: transaction_id).update(state: 'voided')
      end

      result
    end

    def credit(credit_cents, transaction_id, _options)
      Transaction.new(provider, transaction_id).refund(credit_cents.to_f/100)
    end

    def customer_payment_methods(order)
      @utils = Utils.new(self, order)
      @utils.customer_payment_methods
    end

    private

    def sale(data, order)
      result = Transaction.new(provider).sale(data)

      if result.success?
        update_addresses(result, order)
      else
        add_order_errors(result, order)
      end

      result
    end

    def update_addresses(response, order)
      shipping_address = order.shipping_address
      billing_address = order.billing_address
      transaction = response.transaction

      details_id = if shipping_address.same_as?(billing_address)
                     transaction.shipping_details.id
                   else
                     transaction.billing_details.id
                   end

      shipping_address.update_attribute(:braintree_id, transaction.shipping_details.id)
      billing_address.update_attribute(:braintree_id, details_id)
    end

    def add_order_errors(response, order)
      response.errors.each { |e| order.errors.add(:base, I18n.t(e.message), scope: 'braintree.error') }
      return unless response.errors.size.zero? && response.transaction.try(:gateway_rejection_reason)
      order.errors.add(:base, I18n.t(response.transaction.gateway_rejection_reason, scope: 'braintree.error'))
    end

    def set_basic_purchase_data(identifier_hash, order, utils)
      data = {}
      data.merge!(utils.get_customer)
      data.merge!(utils.order_data(identifier_hash))
      return data unless preferred_pass_billing_and_shipping_address

      data.merge!(utils.get_address('billing')) unless order.shipping_address.same_as?(order.billing_address)
      data.merge!(utils.get_address('shipping'))
    end

  end
end