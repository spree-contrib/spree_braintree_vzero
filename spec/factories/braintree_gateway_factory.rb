FactoryGirl.define do
  factory :vzero_gateway, class: Spree::Gateway::BraintreeVzeroDropInUI do
    name 'Braintree Vzero DropInUI'

    transient do
      merchant_id nil
      public_key nil
      private_key nil
    end

    before(:create) do |gateway, s|
      %w(merchant_id private_key public_key).each do |preference|
        gateway.send "preferred_#{preference}=", s.send(preference) || Rails.application.secrets.send(preference)
      end
      gateway.send 'preferred_server=', :sandbox
    end

    factory :vzero_paypal_gateway, class: Spree::Gateway::BraintreeVzeroPaypalExpress do
      name 'Braintree Vzero PayPal Express'
    end

    factory :vzero_dropin_ui_gateway, class: Spree::Gateway::BraintreeVzeroDropInUI do
      name 'Braintree Vzero DropIn UI'
    end

    factory :vzero_dropin_ui_gateway_2, class: Spree::Gateway::BraintreeVzeroDropInUI do
      name 'Braintree Vzero DropIn UI 2'
      active false
    end

    factory :vzero_hosted_fields_gateway, class: Spree::Gateway::BraintreeVzeroHostedFields do
      name 'Braintree Vzero Hosted Fields'
    end

    factory :vzero_hosted_fields_gateway_2, class: Spree::Gateway::BraintreeVzeroHostedFields do
      name 'Braintree Vzero Hosted Fields 2'
      active false
    end
  end
end
