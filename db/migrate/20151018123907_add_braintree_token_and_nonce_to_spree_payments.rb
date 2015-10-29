class AddBraintreeTokenAndNonceToSpreePayments < ActiveRecord::Migration
  def change
    add_column :spree_payments, :braintree_token, :string
    add_column :spree_payments, :braintree_nonce, :string
  end
end
