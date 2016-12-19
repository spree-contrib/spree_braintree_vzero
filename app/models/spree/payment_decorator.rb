Spree::Payment.class_eval do
  alias_method :original_update_order, :update_order

  def update_order
    # without reload order was updated with inaccurate data
    order.reload
    original_update_order
  end
end