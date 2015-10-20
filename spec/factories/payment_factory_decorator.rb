FactoryGirl.define do
  factory :braintree_vzero_payment, class: Spree::Payment do
    amount 12.73
    association(:payment_method, factory: :vzero_gateway)
    association(:source, factory: :braintree_checkout)
    order
    state 'checkout'
    braintree_nonce 'fake-valid-nonce'
  end
end
