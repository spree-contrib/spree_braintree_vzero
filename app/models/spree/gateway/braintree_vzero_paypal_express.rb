module Spree
  class Gateway::BraintreeVzeroPaypalExpress < Spree::Gateway::BraintreeVzeroBase
    preference :paypal_display_on_cart, :boolean_select, default: true
    preference :store_payments_in_vault, :select, default: { values: [:do_not_store, :store_all] }
    preference :paypal_display_name, :string
    preference :checkout_form_id, :string, default: 'checkout_form_payment'
    preference :error_messages_container_id, :string, default: 'content'

    def method_type
      'braintree_vzero_paypal_express'
    end

    def push_order_to_state(order, state, email)
      order.update_column(:email, email)
      order.next! until order.state.eql?(state)
      order.update_column(:email, nil)
    end

    def find_identifier_hash(payment, utils)
      token = payment[:braintree_token] || vaulted_token_by_email(payment, utils)
      if token.present?
        { payment_method_token: token }
      else
        { payment_method_nonce: payment[:braintree_nonce] }
      end
    end

    private

    def vaulted_token_by_email(payment, utils)
      utils.customer_payment_methods('paypal').find do |customer_payment|
        customer_payment.try(:email).eql?(payment.source.paypal_email)
      end.try(:token)
    end
  end
end
