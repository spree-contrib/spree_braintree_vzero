Deface::Override.new(
  virtual_path: 'spree/payments/_payment',
  name: 'Displays payment data for PayPal Express payment methods',
  replace: 'erb[silent]:contains("else")',
  text: %Q{
          <% elsif (last_digits = payment.source.braintree_last_digits) %>
            <%
              cc_type = payment.source.braintree_card_type
              img = "credit_cards/icons/" + cc_type.downcase + ".png"
            %>
            <% if Rails.application.assets.find_asset(img) %>
              <%= image_tag img %>
            <% else %>
              <p><%= Spree.t(:cc_type) + ": " + cc_type %></p>
              </br>
            <% end %>
            <p><%= Spree.t(:ending_in) + " " + last_digits %></p>

          <% elsif (paypal_email = payment.source.paypal_email) %>
            <!-- PayPal Logo --><img src="https://www.paypalobjects.com/webstatic/mktg/logo/pp_cc_mark_37x23.jpg" border="0" alt="PayPal Logo"><!-- PayPal Logo -->
            <%= paypal_email %>

          <% else %>
        }
)
