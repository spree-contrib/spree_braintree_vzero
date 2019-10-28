module Spree
  module PaymentProcessingDecorator
    def self.prepended(base)
      base.delegate :settle, to: :provider
    end

    def settle!
      handle_payment_preconditions { process_settle }
    end

    def gateway_action(source, action, success_state)
      protect_from_connection_error do
        response = payment_method.send(action, money.money.cents,
                                       source,
                                       gateway_options)
        success_state = set_proper_state(success_state, response, action)
        handle_response(response, success_state, :failure)
      end
    end

    private

    def process_settle
      started_processing!
      gateway_action(source, :settle, :started_processing)
    end

    def gateway_error(error)
      if error.is_a? ActiveMerchant::Billing::Response
        text = error.params['message'] || error.params['response_reason_text'] || error.message
      elsif error.is_a? ActiveMerchant::ConnectionError
        text = Spree.t(:unable_to_connect_to_gateway)
      elsif error.is_a? Braintree::ErrorResult
        text = error.message
      else
        text = error.to_s
      end
      logger.error(Spree.t(:gateway_error))
      logger.error("  #{error.to_yaml}")
      raise Spree::Core::GatewayError, text
    end

    def set_proper_state(current_state, response, action)
      return current_state unless action.eql?(:purchase)
      return current_state unless source.is_a?(Spree::BraintreeCheckout)
      utils = Spree::Gateway::BraintreeVzeroBase::Utils.new(payment_method, order)
      state = utils.map_payment_status(response.try(:transaction).try(:status))

      case state
      when 'completed'
        'complete'
      when 'pending'
        'pend'
      else
        current_state
      end
    end
  end
end

::Spree::Payment.prepend(Spree::PaymentProcessingDecorator)
