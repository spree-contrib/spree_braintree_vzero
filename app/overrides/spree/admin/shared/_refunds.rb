Deface::Override.new(
  virtual_path: 'spree/admin/shared/_refunds',
  name: 'Remove refund edit button',
  surround: 'erb[loud]:contains("edit_admin_order_payment_refund_path")',
  text: '<% unless refund.payment.source_type.eql?(Spree::BraintreeCheckout.to_s) %><%= render_original %><% end %>'
)

