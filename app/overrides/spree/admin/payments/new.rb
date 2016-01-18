Deface::Override.new(
  virtual_path: 'spree/admin/payments/new',
  name: 'Adds necessary buttons for Braintree payment methods',
  insert_after: 'erb[loud]:contains("button")',
  partial: 'spree/admin/payments/source_forms/braintree_vzero/buttons'
)

Deface::Override.new(
  virtual_path: 'spree/admin/payments/new',
  name: 'Add control class to update button',
  replace: %{erb[loud]:contains("Spree.t('actions.update')")},
  text: "<%= button @order.cart? ? Spree.t('actions.continue') : Spree.t('actions.update'), @order.cart? ? 'arrow-right' : 'refresh base-btn' %>"
)

