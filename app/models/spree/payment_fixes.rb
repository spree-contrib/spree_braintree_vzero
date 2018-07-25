module Spree
  module PaymentFixes

    def update_order
      # without reload order was updated with inaccurate data
      order.reload
      super
    end
  end
end
