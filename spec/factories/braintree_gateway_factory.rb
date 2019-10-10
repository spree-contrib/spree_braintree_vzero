FactoryBot.define do
  factory :vzero_gateway, class: Spree::Gateway::BraintreeVzeroDropInUi do
    name { 'Braintree Vzero DropInUI' }

    # to write new specs please provide proper credentials
    # either here or in dummy secrets.yml file. Values will
    # be recorded on VCR, so they can be safely replaced with
    # placeholder afterwards
    transient do
      merchant_id { Rails.application.secrets.merchant_id || 'change me' }
      public_key { Rails.application.secrets.public_key || 'change me' }
      private_key { Rails.application.secrets.private_key || 'change me' }
    end

    before(:create) do |gateway, s|
      %w(merchant_id private_key public_key).each do |preference|
        gateway.send "preferred_#{preference}=", s.send(preference)
      end
      gateway.send 'preferred_server=', :sandbox
      gateway.preferences[:currency_merchant_accounts] = { 'EUR' => 'sparksolutions_EUR' }
    end

    factory :vzero_paypal_gateway, class: Spree::Gateway::BraintreeVzeroPaypalExpress do
      name { 'Braintree Vzero PayPal Express' }
    end

    factory :vzero_dropin_ui_gateway, class: Spree::Gateway::BraintreeVzeroDropInUi do
      name { 'Braintree Vzero DropIn UI' }
    end

    factory :vzero_hosted_fields_gateway, class: Spree::Gateway::BraintreeVzeroHostedFields do
      name { 'Braintree Vzero Hosted Fields' }
    end
  end
end
