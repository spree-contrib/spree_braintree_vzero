class AddAdminPaymentToSpreeBraintreeCheckout < ActiveRecord::Migration
  def change
    add_column :spree_braintree_checkouts, :admin_payment, :bool
  end
end
