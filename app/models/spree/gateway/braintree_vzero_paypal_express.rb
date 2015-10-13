module Spree
  class Gateway::BraintreeVzeroPaypalExpress < Spree::Gateway::BraintreeVzeroBase
    preference :paypal_display_on_cart, :boolean_select, default: true
  end
end
