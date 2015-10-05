Deface::Override.new(
  virtual_path: 'spree/admin/refunds/new',
  name: 'Remove amount label',
  surround: 'erb[loud]:contains("Spree.t(:amount)")',
  text: '<% unless @refund.payment.source_type.eql?(Spree::BraintreeCheckout.to_s) %><%= render_original %><% end %>'
)

Deface::Override.new(
  virtual_path: 'spree/admin/refunds/new',
  name: 'Hide amount text field',
  surround: 'erb[loud]:contains("f.text_field :amount")',
  text: "<% if @refund.payment.source_type.eql?(Spree::BraintreeCheckout.to_s) %>
           <%= f.hidden_field :amount, class: 'form-control' %>
         <% else %>
           <%= render_original %>
         <% end %>"
)
