module Spree
  class Gateway::BraintreeVzeroStandard < Spree::Gateway::BraintreeVzeroBase
    preference :ui_kind, :select, default: -> {{values: [:dropin, :hosted]}}
    preference :dropin_container, :string, default: 'payment-form'
    preference :dropin_checkout_form_id, :string, default: 'checkout_form_payment'
    preference :dropin_error_messages_container_id, :string, default: 'content'
    preference :hosted_container, :string, default: 'payment-form'
    preference :hosted_number_selector, :string, default: '#hosted-fields-number'
    preference :hosted_number_placeholder, :string, default: I18n.t(:number, scope: 'braintree.preferences.placeholder')
    preference :hosted_cvv_selector, :string, default: '#hosted-fields-cvv'
    preference :hosted_cvv_placeholder, :string, default: I18n.t(:cvv, scope: 'braintree.preferences.placeholder')
    preference :hosted_expiration_date_selector, :string, default: '#hosted-fields-expiration-date'
    preference :hosted_expiration_date_placeholder, :string, default: I18n.t(:expiration_date, scope: 'braintree.preferences.placeholder')



    def reject_preferences
      preferred_ui_kind == 'dropin' ? 'hosted' : 'dropin'
    end

    def ui_kind
      preferred_ui_kind == 'dropin' ? 'dropin' : 'custom'
    end

  end
end
