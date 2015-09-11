class CreateSpreeBraintreeCheckouts < ActiveRecord::Migration
  def change
    create_table :spree_braintree_checkouts do |t|
      t.string :transaction_id, index: true
      t.string :state, index: true
      t.timestamps
    end
  end
end
