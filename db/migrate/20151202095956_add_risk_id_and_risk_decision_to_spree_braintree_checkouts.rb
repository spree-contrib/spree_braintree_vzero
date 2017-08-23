class AddRiskIdAndRiskDecisionToSpreeBraintreeCheckouts < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_braintree_checkouts, :risk_id, :string
    add_column :spree_braintree_checkouts, :risk_decision, :string
  end
end
