module Spree
  class Gateway::BraintreeVzeroPaypalExpress < Spree::Gateway::BraintreeVzeroBase
    preference :paypal_display_on_cart, :boolean_select, default: true
    preference :store_payments_in_vault, :select, default: -> { { values: [:do_not_store, :store_all] } }

    def push_order_to_delivery(order, email)
      order.update_column(:email, email)
      order.next! until order.state.eql?('delivery')
    end
  end
end
