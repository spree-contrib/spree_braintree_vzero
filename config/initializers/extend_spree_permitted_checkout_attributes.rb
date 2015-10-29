module Spree
  module PermittedAttributes
    @@payment_attributes = [:amount, :payment_method_id, :payment_method, :braintree_token, :braintree_nonce]
  end
end
