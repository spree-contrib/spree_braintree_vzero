module Spree
  class Gateway::BraintreeVzeroPaypalExpress < Spree::Gateway::BraintreeVzeroBase
    preference :paypal_display_on_cart, :boolean_select, default: true
    preference :store_payments_in_vault, :select, default: -> { { values: [:do_not_store, :store_all] } }
    preference :paypal_display_name, :string

    def push_order_to_state(order, state, email)
      order.update_column(:email, email)
      order.next! until order.state.eql?(state)
      order.update_column(:email, nil)
    end

    def find_identifier_hash(payment, utils)
      token = payment[:braintree_token] || utils.customer_payment_methods.find do |customer_payment|
        customer_payment.try(:email).eql?(payment.source.paypal_email)
      end.try(:token)

      if (token).present?
        { payment_method_token: token }
      else
        { payment_method_nonce: payment[:braintree_nonce] }
      end
    end
  end
end
