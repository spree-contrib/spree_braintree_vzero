require 'braintree'
module Spree
  class Gateway::BraintreeVzero < Gateway
    preference :merchant_id, :string
    preference :public_key, :string
    preference :private_key, :string
    preference :server, :string, default: :sandbox

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

      result = provider::Transaction.sale(
          amount: order.total,
          payment_method_nonce: nonce,
          options: {
              submit_for_settlement: true
          }
      )
      unless result.success?
        result.errors.each { |e| order.errors.add(:braintree_error, e.message) }
      end
      result
    end

    def complete_order(order, result, payment_method)
      return false unless result.transaction
      payment = order.payments.create!({
                                           source: Spree::BraintreeCheckout.create!(transaction_id: result.transaction.id, state: result.transaction.status),
                                           amount: order.total,
                                           payment_method: payment_method,
                                           state: map_payment_status(result.transaction.status)
                                       })
      payment.started_processing!
      payment.pend!
      order.update_attributes(completed_at: Time.zone.now, state: :complete)
      order.finalize!
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
