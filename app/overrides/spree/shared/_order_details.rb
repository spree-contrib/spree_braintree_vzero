Deface::Override.new(
  virtual_path: 'spree/shared/_order_details',
  name: 'Displays payment data for PayPal Express payment methods',
  replace: %{erb[silent]:contains('order.has_step?("payment")')},
  text: '<% if @order.has_step?("payment") || @order.paid_with_paypal_express? %>'
)

Deface::Override.new(
  virtual_path: 'spree/shared/_order_details',
  name: 'Removes redirect to payment step when there is no payment',
  replace: 'erb[loud]:contains("checkout_state_path(:payment) unless order.completed?")',
  text: '<%= link_to "(#{Spree.t(:edit)})", checkout_state_path(:payment) unless order.completed? || order.paid_with_paypal_express? %>'
)
