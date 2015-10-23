Spree::CheckoutController.class_eval do
  after_action :allow_braintree_iframe

  private

  def allow_braintree_iframe
    response.headers['X-Frame-Options'] = 'ALLOW-FROM https://assets.braintreegateway.com'
  end

  def check_registration
    return unless Spree::Auth::Config[:registration_step]
    paypal_express = current_order.payments.valid.map(&:payment_method).compact.any? { |p| p.kind_of?(Spree::Gateway::BraintreeVzeroPaypalExpress) }
    return if spree_current_user || (!paypal_express && current_order.email)
    store_location
    redirect_to spree.checkout_registration_path
  end

end
