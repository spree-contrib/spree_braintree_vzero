module Spree
  module PermittedAttributes
    @@payment_attributes = [:amount, :payment_method_id, :payment_method, :braintree_token, :braintree_nonce]
    @@source_attributes = [
      :number, :month, :year, :expiry, :verification_value,
      :first_name, :last_name, :cc_type, :gateway_customer_profile_id,
      :gateway_payment_profile_id, :last_digits, :name, :encrypted_data,
      # Add Braintree params to allow source to be created
      :braintree_last_two, :braintree_card_type, :braintree_nonce
    ]
  end
end
