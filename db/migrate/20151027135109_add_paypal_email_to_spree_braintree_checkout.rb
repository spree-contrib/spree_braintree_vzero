class AddPaypalEmailToSpreeBraintreeCheckout < ActiveRecord::Migration
  def change
    add_column :spree_braintree_checkouts, :paypal_email, :string
  end
end
