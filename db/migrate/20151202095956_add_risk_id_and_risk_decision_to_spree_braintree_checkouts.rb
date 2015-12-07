class AddRiskIdAndRiskDecisionToSpreeBraintreeCheckouts < ActiveRecord::Migration
  def change
    add_column :spree_braintree_checkouts, :risk_id, :string
    add_column :spree_braintree_checkouts, :risk_decision, :string
  end
end
