module Spree
  class Gateway::BraintreeVzeroStandard < Spree::Gateway::BraintreeVzeroBase
    preference :ui_kind, :select, default: -> {{values: [:dropin, :hosted]}}
    preference :dropin_container, :string, default: 'payment-form'
    preference :dropin_checkout_form_id, :string, default: 'checkout_form_payment'
    preference :dropin_error_messages_container_id, :string, default: 'content'


    def reject_preferences
      preferred_ui_kind == 'dropin' ? 'hosted' : 'dropin'
    end

    def ui_kind
      preferred_ui_kind == 'dropin' ? 'dropin' : 'custom'
    end

  end
end
