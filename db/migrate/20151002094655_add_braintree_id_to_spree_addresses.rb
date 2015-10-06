class AddBraintreeIdToSpreeAddresses < ActiveRecord::Migration
  def change
    add_column :spree_addresses, :braintree_id, :string
  end
end
