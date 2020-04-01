module Spree
  module BraintreeHelper
    def options_from_braintree_payments(payment_methods, include_empty = false)
      additional_options = if include_empty
                             ["<option value=''>#{t('braintree.checkout.blank_saved_payment_method')}</option>"]
                           else
                             []
                           end
      additional_options + payment_methods.map do |method|
        text = if method.is_a?(Braintree::CreditCard)
                 Spree.t('admin.vaulted_payments.credit_card', card_type: method.card_type, last_4: method.last_4)
               elsif method.is_a?(Braintree::PayPalAccount)
                 Spree.t('admin.vaulted_payments.paypal', email: method.email)
               end
        "<option value='#{method.token}'>#{text}</option>"
      end.join.html_safe
    end

    def asset_available?(logical_path)
      if Rails.configuration.assets.compile
        Rails.application.precompiled_assets.include? logical_path
      else
        Rails.application.assets_manifest.assets[logical_path].present?
      end
    end
  end
end
