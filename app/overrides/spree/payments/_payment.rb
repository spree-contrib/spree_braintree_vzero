Deface::Override.new(
  virtual_path: 'spree/payments/_payment',
  name: 'Displays payment data for PayPal Express payment methods',
  replace: 'erb[silent]:contains("else")',
  text: %Q{
           <% elsif payment.payment_method.is_a?(Spree::Gateway::BraintreeVzeroPaypalExpress) %>
             <!-- PayPal Logo --><img src="https://www.paypalobjects.com/webstatic/mktg/logo/pp_cc_mark_37x23.jpg" border="0" alt="PayPal Logo"><!-- PayPal Logo -->
             <%= payment.source.try(:paypal_email) %>
           <% else %>
        }
)
