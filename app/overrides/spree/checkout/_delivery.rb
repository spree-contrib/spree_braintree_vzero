Deface::Override.new(
  virtual_path: 'spree/checkout/_delivery',
  name: 'Add payment method id field',
  insert_before: 'erb[loud]:contains("form.fields_for :shipments")',
  text: '<% if (payment_method_id = params["payment_method_id"]).present? %>
           <%= hidden_field_tag "order[payments_attributes][][payment_method_id]", payment_method_id %>
           <%= hidden_field_tag "payment_method_nonce", params["payment_method_nonce"] %>
         <% end %>'
)
