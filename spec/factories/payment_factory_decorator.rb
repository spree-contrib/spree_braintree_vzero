FactoryBot.define do
  factory :braintree_vzero_payment, class: Spree::Payment do
    amount { 12.73 }
    association(:payment_method, factory: :vzero_gateway)
    association(:source, factory: :braintree_checkout)
    order
    state { 'checkout' }
    braintree_nonce { 'fake-valid-nonce' }
  end

  factory :braintree_vzero_paypal_payment, class: Spree::Payment do
    amount { 0 }
    association(:payment_method, factory: :vzero_paypal_gateway)
    association(:source, factory: :braintree_checkout)
    order
    state { 'checkout' }
    braintree_nonce { 'fake-valid-nonce' }
  end

  factory :braintree_vzero_failed_paypal_payment, class: Spree::Payment do
    amount { 0 }
    association(:payment_method, factory: :vzero_paypal_gateway)
    association(:source, factory: :braintree_checkout)
    order
    state { 'checkout' }
    braintree_nonce { 'fake-invalid-nonce' }
  end
end
