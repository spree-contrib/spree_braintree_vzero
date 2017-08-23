class AddAdminPaymentToSpreeBraintreeCheckout < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_braintree_checkouts, :admin_payment, :bool
  end
end
