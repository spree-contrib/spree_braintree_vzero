Deface::Override.new(
  virtual_path: 'spree/admin/payments/_list',
  name: 'Add link with icon for settle action',
  insert_after: 'erb[loud]:contains("new_admin_order_payment_refund_path")',
  text: '<% elsif action == "settle" %>
         <%= link_to_with_icon "capture", Spree.t(:settle), fire_admin_order_payment_path(@order, payment, :e => action), :method => :put, :no_text => true, :data => {:action => action}  %>'
)
