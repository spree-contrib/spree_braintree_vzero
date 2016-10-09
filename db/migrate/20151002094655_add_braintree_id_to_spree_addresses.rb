class AddBraintreeIdToSpreeAddresses < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_addresses, :braintree_id, :string
  end
end
