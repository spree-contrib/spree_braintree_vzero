FactoryBot.define do
  factory :braintree_checkout, class: Spree::BraintreeCheckout do
    factory :braintree_checkout_with_fraud_data, class: Spree::BraintreeCheckout do
      advanced_fraud_data { '{"device_session_id":"9cc1d185d71768c185c06622b7ca7cfe","fraud_merchant_id":"600000","correlation_id":"7343097f536f584bfded32f9d229ec6d"}' }
    end
  end
end
