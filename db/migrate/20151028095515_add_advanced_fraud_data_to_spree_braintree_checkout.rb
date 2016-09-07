class AddAdvancedFraudDataToSpreeBraintreeCheckout < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_braintree_checkouts, :advanced_fraud_data, :string
  end
end
