FactoryGirl.define do
  factory :vzero_gateway, class: Spree::Gateway::BraintreeVzeroStandard do
    name 'Braintree Vzero Base'

    transient do
      merchant_id nil
      public_key nil
      private_key nil
    end

    before(:create) do |gateway, s|
      %w(merchant_id private_key public_key).each do |preference|
        gateway.send "preferred_#{preference}=", s.send(preference) || Rails.application.secrets.send(preference)
      end
    end
  end
end
