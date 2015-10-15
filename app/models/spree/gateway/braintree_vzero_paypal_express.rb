module Spree
  class Gateway::BraintreeVzeroPaypalExpress < Spree::Gateway::BraintreeVzeroBase
    preference :paypal_display_on_cart, :boolean_select, default: true

    def push_order_to_delivery(order, email)
      order.update_column(:email, email)
      order.next! until order.state.eql?('delivery')
      order.update_column(:email, nil)
    end
  end
end
