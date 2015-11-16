Deface::Override.new(
  virtual_path: 'spree/admin/orders/index',
  name: 'Add clone order button',
  insert_after: 'erb[loud]:contains("link_to_edit_url")',
  text: "&nbsp;<%= link_to_with_icon('clone', Spree.t(:clone), clone_admin_order_path(order), no_text: true, class: 'btn btn-primary btn-sm clone', data: { action: 'clone' }) if can?(:clone, order) %>"
)
