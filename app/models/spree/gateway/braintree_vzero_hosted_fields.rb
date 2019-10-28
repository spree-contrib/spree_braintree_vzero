module Spree
  class Gateway::BraintreeVzeroHostedFields < Spree::Gateway::BraintreeVzeroBase
    preference :checkout_form_id, :string, default: 'checkout_form_payment'
    preference :error_messages_container_id, :string, default: 'content'
    preference :number_selector, :string, default: '#hosted-fields-number'
    preference :number_placeholder, :string, default: 'Card Number'
    preference :cvv_selector, :string, default: '#hosted-fields-cvv'
    preference :cvv_placeholder, :string, default: 'Cvv code'
    preference :expiration_date_selector, :string, default: '#hosted-fields-expiration-date'
    preference :expiration_date_placeholder, :string, default: 'Card Expiration Date'
    preference :store_payments_in_vault, :select, default: -> { { values: [:do_not_store, :store_only_on_success, :store_all] } }
    preference :'3dsecure', :boolean_select, default: false

    after_save :disable_dropin_gateways, if: proc {
      active? && (saved_changes.keys & %w[active id]).any?
    }

    def method_type
      'braintree_vzero_hosted_fields'
    end

    private

    def disable_dropin_gateways
      Spree::Gateway::BraintreeVzeroDropInUi.update_all(active: false)
    end
  end
end
