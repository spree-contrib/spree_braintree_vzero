Deface::Override.new(
  virtual_path: 'spree/orders/edit',
  name: 'Add PayPal button',
  insert_top: '[data-hook="cart_buttons"]',
  partial: 'spree/braintree_vzero/paypal_checkout'
)
