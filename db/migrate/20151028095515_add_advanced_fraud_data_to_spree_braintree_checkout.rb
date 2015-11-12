class AddAdvancedFraudDataToSpreeBraintreeCheckout < ActiveRecord::Migration
  def change
    add_column :spree_braintree_checkouts, :advanced_fraud_data, :string
  end
end
