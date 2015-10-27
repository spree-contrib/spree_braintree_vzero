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
  end
end
