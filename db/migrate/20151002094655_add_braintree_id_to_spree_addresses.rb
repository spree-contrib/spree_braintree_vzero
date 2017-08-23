class AddBraintreeIdToSpreeAddresses < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_addresses, :braintree_id, :string
  end
end
