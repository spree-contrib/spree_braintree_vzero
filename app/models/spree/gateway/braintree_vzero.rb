require 'braintree'
module Spree
  class Gateway::BraintreeVzero < Gateway
    preference :merchant_id, :string
    preference :public_key, :string
    preference :private_key, :string
    preference :server, :string, default: :sandbox
    preference '3dsecure', :boolean, default: true
    preference :pass_billing_and_shipping_address, :boolean, default: true

    attr_reader :utils

    def self.current
      super
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

    def client_token
      provider::ClientToken.generate
    end

    def purchase(nonce, order)
      @utils = BraintreeUtils.new(order)
      data = {}
      if preferred_pass_billing_and_shipping_address
        data.merge!(billing: @utils.address_data('billing'))
        data.merge!(shipping: @utils.address_data('shipping'))
      end
      data.merge!(@utils.order_data(nonce))
      data.merge!(
        options: {
          submit_for_settlement: true,
          three_d_secure: {
            required: preferred_3dsecure
          }
        }
      )

      result = provider::Transaction.sale(data)

      unless result.success?
        result.errors.each { |e| order.errors.add(:braintree_error, e.message) }
      end
      if result.transaction.try(:gateway_rejection_reason) == Braintree::Transaction::GatewayRejectionReason::ThreeDSecure
        order.errors.add(:braintree_error, 'three_d_secure_validation_failed')
      end

      result
    end

    def complete_order(order, result, payment_method)
      return false unless result.transaction
      payment = order.payments.create!(
        source: Spree::BraintreeCheckout.create!(transaction_id: result.transaction.id, state: result.transaction.status),
        amount: order.total,
        payment_method: payment_method,
        state: map_payment_status(result.transaction.status),
        response_code: result.transaction.id
      )
      payment.save!
      order.update_attributes(completed_at: Time.zone.now, state: :complete)
      order.finalize!
      order.update!
    end

    def map_payment_status(braintree_status)
      case braintree_status
      when 'authorized'
        'pending'
      when 'voided'
        'void'
      when 'submitted_for_settlement', 'settling', 'settlement_pending' #TODO: can we treat it as paid?
        'completed'
      when 'settled'
        'completed'
      else
        'failed'
      end
    end

  end
end
