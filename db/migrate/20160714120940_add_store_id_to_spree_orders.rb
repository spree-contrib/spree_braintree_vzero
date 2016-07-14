class AddStoreIdToSpreeOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :store_id, :integer
    add_index :spree_orders, :store_id
  end
end
