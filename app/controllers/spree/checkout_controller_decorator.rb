module Spree
  module CheckoutControllerDecorator
    def self.prepended(base)
      base.include Spree::BraintreeHelper
      base.helper_method [:asset_available?, :options_from_braintree_payments]
      base.after_action :allow_braintree_iframe
      base.after_action :update_source_data, only: :update, if: proc { params[:state].eql?('payment') }
    end

    private

    def allow_braintree_iframe
      response.headers['X-Frame-Options'] = 'ALLOW-FROM https://assets.braintreegateway.com'
    end

    def check_registration
      return unless Spree::Auth::Config[:registration_step]
      return if spree_current_user || current_order.email
      store_location
      redirect_to spree.checkout_registration_path
    end

    def update_source_data
      return true unless current_order
      payment = current_order.payments.last
      return true unless payment
      source = payment.source
      return true unless source.is_a?(Spree::BraintreeCheckout)
      update_advanced_fraud_data(source)
    end

    def update_advanced_fraud_data(source)
      source.update(advanced_fraud_data: params[:device_data])
    end
  end
end

::Spree::CheckoutController.prepend(Spree::CheckoutControllerDecorator)
