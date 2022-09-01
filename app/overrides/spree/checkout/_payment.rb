Deface::Override.new(
  virtual_path: 'spree/checkout/_payment',
  name: 'Modifies Paypal Express payment method on checkout',
  surround: 'erb[loud]:contains("Spree.t(method.name, :scope => :payment_methods, :default => method.name)")',
  text: %{
    <% if method.is_a?(Spree::Gateway::BraintreeVzeroPaypalExpress) %>
      <img src="https://www.paypalobjects.com/webstatic/mktg/logo/pp_cc_mark_37x23.jpg" border="0" alt="PayPal Logo">
      <a href="https://www.paypal.com/webapps/mpp/paypal-popup" title="<%= Spree.t(:how_paypal_works) %>" onclick="javascript:window.open('https://www.paypal.com/webapps/mpp/paypal-popup', 'WIPaypal','toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=yes, resizable=yes, width=1060, height=700'); return false;"> <%= Spree.t(:what_is_paypal) %></a>
    <% else %>
      <%= render_original %>
    <% end %>
  }
)

Deface::Override.new(
  virtual_path: 'spree/checkout/_payment',
  name: 'Adds necessary buttons for Braintree payment methods',
  insert_after: 'erb[loud]:contains("submit_tag")',
  partial: 'spree/checkout/payment/braintree_vzero/buttons'
)
