module Spree
  module PaymentDecorator
    def update_order
      # without reload order was updated with inaccurate data
      order.reload && super
    end
  end
end

::Spree::Payment.prepend(Spree::PaymentDecorator)
