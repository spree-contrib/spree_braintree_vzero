require 'braintree'

module Spree
  class Gateway::BraintreeVzeroBase < Gateway
    include BraintreeVzeroBase::PurchaseData

    preference :merchant_id, :string
    preference :public_key, :string
    preference :private_key, :string
    preference :server, :select, default: -> { { values: [:sandbox, :production] } }
    preference :pass_billing_and_shipping_address, :boolean_select, default: false
    preference :kount_merchant_id, :string
    preference :advanced_fraud_tools, :boolean_select, default: false
    preference :descriptor_name, :string
    preference :currency_merchant_accounts, :hash, default: {}

    attr_reader :utils

    def self.current
      super
    end

    def provider_class
      Braintree
    end

    def provider
      Braintree::Configuration.environment = preferred_server.to_sym
      Braintree::Configuration.merchant_id = preferred_merchant_id
      Braintree::Configuration.public_key = preferred_public_key
      Braintree::Configuration.private_key = preferred_private_key
      Braintree
    end

    def client_token(order = nil, user = nil)
      braintree_provider = provider
      braintree_provider::ClientToken.generate token_params(braintree_provider, user, order)
    end

    def purchase(money_in_cents, source, gateway_options)
      order, payment = order_data_from_options(gateway_options)

      @utils = Utils.new(self, order)
      identifier_hash = find_identifier_hash(payment, @utils)

      data = set_purchase_data(identifier_hash, order, money_in_cents, source)

      return invalid_payment_error(data) if identifier_hash.values.all?(&:blank?)
      sale(data, order, payment.source)
    end

    def authorize(money_in_cents, source, gateway_options)
      purchase money_in_cents, source, gateway_options
    end

    def settle(amount, checkout, _gateway_options)
      result = Transaction.new(provider, checkout.transaction_id).submit_for_settlement(amount / 100.0)
      checkout.update(state: result.transaction.status)
      result
    end

    def capture(amount, transaction_id, _gateway_options)
      checkout = Spree::BraintreeCheckout.find_by(transaction_id: transaction_id)
      settle(amount, checkout, _gateway_options)
    end

    def void(transaction_id, _data)
      result = Transaction.new(provider, transaction_id).void

      if result.success?
        Spree::BraintreeCheckout.find_by(transaction_id: transaction_id).update(state: 'voided')
      end

      result
    end

    def credit(credit_cents, transaction_id, _options)
      Transaction.new(provider, transaction_id).refund(credit_cents.to_f / 100)
    end

    def customer_payment_methods(order, payment_method_type)
      @utils = Utils.new(self, order)
      @utils.customer_payment_methods(payment_method_type)
    end

    def vaulted_payment_method(token)
      provider::PaymentMethod.find(token)
    end

    private

    def sale(data, order, source = nil)
      Rails.logger.info "Sale data: #{data.inspect}"
      result = Transaction.new(provider).sale(data)
      Rails.logger.info "Risk Data: #{result.transaction.risk_data.inspect}" if result.success?

      if result.success?
        update_addresses(result, order)
        update_source(result, source)
      else
        add_order_errors(result, order)
      end

      result
    end

    def update_addresses(response, order)
      shipping_address = order.shipping_address
      billing_address = order.billing_address
      transaction = response.transaction

      shipping_details_id = transaction.shipping_details.id
      details_id = if shipping_address.same_as?(billing_address)
                     shipping_details_id ||= transaction.billing_details.id
                   else
                     transaction.billing_details.id
                   end

      shipping_address.update_attribute(:braintree_id, shipping_details_id)
      billing_address.update_attribute(:braintree_id, details_id)
    end

    def update_source(response, source)
      return unless source.present?
      transaction = response.transaction
      if (risk_data = transaction.risk_data).present?
        source.update(transaction_id: transaction.id, state: transaction.status,
                      risk_id: risk_data.id, risk_decision: risk_data.decision)
      else
        source.update(transaction_id: transaction.id, state: transaction.status)
      end
    end

    def add_order_errors(response, order)
      response.errors.each { |e| order.errors.add(:base, I18n.t(e.message), scope: 'braintree.error') }
      return unless response.errors.size.zero? && response.transaction.try(:gateway_rejection_reason)
      order.errors.add(:base, I18n.t(response.transaction.gateway_rejection_reason, scope: 'braintree.error'))
    end

    def find_identifier_hash(payment, _utils)
      if (token = payment[:braintree_token]).present?
        { payment_method_token: token }
      else
        { payment_method_nonce: payment[:braintree_nonce] }
      end
    end

    def invalid_payment_error(data)
      # We want only direct choice of payment method (token or nonce), not by customer_id
      message = 'Payment method identification was not specified'
      errors = { errors: [{ code: '0', attribute: '', message: message }] }
      Braintree::ErrorResult.new(:transaction, params: data, errors: { transaction: errors }, message: message)
    end

    def braintree_user(provider, user, order)
      Gateway::BraintreeVzeroBase::User.new(provider, user, order).user
    end

    def token_params(provider, user, order)
      token_params = {}
      token_params[:customer_id] = user.id if braintree_user(provider, user, order)
      currency = order.try(:currency)
      merchant_account_id = currency ? get_merchant_account(currency) : nil
      token_params[:merchant_account_id] = merchant_account_id if merchant_account_id
      token_params
    end
  end
end
