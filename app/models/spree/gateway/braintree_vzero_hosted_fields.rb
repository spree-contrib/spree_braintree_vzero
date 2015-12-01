module Spree
  class Gateway::BraintreeVzeroHostedFields < Spree::Gateway::BraintreeVzeroBase
    preference :checkout_form_id, :string, default: 'checkout_form_payment'
    preference :error_messages_container_id, :string, default: 'content'
    preference :hosted_fields_number_selector, :string, default: '#hosted-fields-number'
    preference :hosted_fields_number_placeholder, :string, default: 'Card Number'
    preference :hosted_fields_cvv_selector, :string, default: '#hosted-fields-cvv'
    preference :hosted_fields_cvv_placeholder, :string, default: 'Cvv code'
    preference :hosted_fields_expiration_date_selector, :string, default: '#hosted-fields-expiration-date'
    preference :hosted_fields_expiration_date_placeholder, :string, default: 'Card Expiration Date'
    preference :store_payments_in_vault, :select, default: -> { { values: [:do_not_store, :store_only_on_success, :store_all] } }
    preference :'3dsecure', :boolean_select, default: false

    after_save :disable_dropin_gateways, if: proc { active? && (active_changed? || id_changed?) }

    private

    def disable_dropin_gateways
      Spree::Gateway::BraintreeVzeroDropInUI.update_all(active: false)
    end
  end
end
