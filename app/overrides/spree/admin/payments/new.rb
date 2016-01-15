Deface::Override.new(
  virtual_path: 'spree/admin/payments/new',
  name: 'Adds necessary buttons for Braintree payment methods',
  insert_after: 'erb[loud]:contains("button")',
  partial: 'spree/admin/payments/source_forms/braintree_vzero/buttons'
)

