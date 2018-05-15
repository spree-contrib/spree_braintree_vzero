module Spree
  class Gateway::BraintreeVzeroDropInUI < Spree::Gateway::BraintreeVzeroBase
    preference :dropin_container, :string, default: 'payment-form'
    preference :checkout_form_id, :string, default: 'checkout_form_payment'
    preference :error_messages_container_id, :string, default: 'content'
    preference :store_payments_in_vault, :select, default: -> { { values: [:do_not_store, :store_only_on_success, :store_all] } }
    preference :'3dsecure', :boolean_select, default: false

    after_save :disable_hosted_gateways, if: proc {
      changed_attributes = changes.keys + previous_changes.keys
      active? && (changed_attributes & %w[active id]).any?
    }

    def method_type
      'braintree_vzero_dropin_ui'
    end

    private

    # we cannot have Hosted and DropInUI both active at the same time
    def disable_hosted_gateways
      Spree::Gateway::BraintreeVzeroHostedFields.update_all(active: false)
    end
  end
end
