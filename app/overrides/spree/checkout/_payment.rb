Deface::Override.new(
  virtual_path: 'spree/checkout/_payment',
  name: 'Removes Paypal Express payment method from checkout',
  insert_after: 'erb[silent]:contains("available_payment_methods")',
  text: '<% next if method.is_a?(Spree::Gateway::BraintreeVzeroPaypalExpress) %>'
)
