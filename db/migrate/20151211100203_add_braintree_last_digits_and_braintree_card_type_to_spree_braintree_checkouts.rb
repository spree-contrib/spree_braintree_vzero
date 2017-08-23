class AddBraintreeLastDigitsAndBraintreeCardTypeToSpreeBraintreeCheckouts < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_braintree_checkouts, :braintree_last_digits, :string, limit: 4
    add_column :spree_braintree_checkouts, :braintree_card_type, :string
  end
end
