module Spree
  class Gateway::BraintreeVzeroDropInUI < Spree::Gateway::BraintreeVzeroBase
    preference :dropin_container, :string, default: 'payment-form'
    preference :dropin_checkout_form_id, :string, default: 'checkout_form_payment'
    preference :dropin_error_messages_container_id, :string, default: 'content'
    preference :store_payments_in_vault, :select, default: -> { { values: [:do_not_store, :store_only_on_success, :store_all] } }
  end
end
