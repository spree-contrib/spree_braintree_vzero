Deface::Override.new(
  virtual_path: 'spree/payments/_payment',
  name: 'Displays payment data for PayPal Express payment methods',
  replace: 'erb[silent]:contains("else")',
  text: %Q{
           <% elsif payment.payment_method.is_a?(Spree::Gateway::BraintreeVzeroPaypalExpress) %>
             <!-- PayPal Logo --><a href="https://www.paypal.com/webapps/mpp/paypal-popup" title="How PayPal Works" onclick="javascript:window.open('https://www.paypal.com/webapps/mpp/paypal-popup','WIPaypal','toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=yes, resizable=yes, width=1060, height=700'); return false;"><img src="https://www.paypalobjects.com/webstatic/mktg/logo/pp_cc_mark_37x23.jpg" border="0" alt="PayPal Logo"></a><!-- PayPal Logo -->
             <%= payment.source.try(:paypal_email) %>
           <% else %>
        }
)
