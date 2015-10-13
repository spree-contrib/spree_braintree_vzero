Deface::Override.new(
  virtual_path: 'spree/admin/orders/cart',
  name: 'Add clone button',
  insert_after: 'erb[silent]:contains("if can?(:resend, @order)")',
  text: "<% if can?(:clone, @order) %>
           <%= button_link_to Spree.t(:clone), clone_admin_order_path(@order), method: :post, icon: 'clone' %>
         <% end %>"
)
