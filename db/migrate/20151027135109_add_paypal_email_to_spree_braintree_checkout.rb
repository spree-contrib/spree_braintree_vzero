class AddPaypalEmailToSpreeBraintreeCheckout < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_braintree_checkouts, :paypal_email, :string
  end
end
