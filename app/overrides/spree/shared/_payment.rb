Deface::Override.new(
  virtual_path: 'spree/shared/_payment',
  name: 'Displays payment data for PayPal Express payment methods',
  replace: 'erb[silent]:contains("else")',
  text: %{
        <% elsif payment.payment_method.kind_of?(Spree::Gateway::BraintreeVzeroBase) %>
          <% if (last_digits = payment.source.braintree_last_digits) %>
            <% cc_type = payment.source.braintree_card_type %>
            <p><%= cc_type %></p>
            <p><%= Spree.t(:ending_in) + " " + last_digits %></p>
          <% end %>
          <% if (paypal_email = payment.source.paypal_email) %>
            <p>Paypal</p>
            <p><%= paypal_email %></p>
          <% end %>
        <% else %>
        }
)
