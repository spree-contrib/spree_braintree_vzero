Spree::CheckoutController.class_eval do
  after_action :allow_braintree_iframe

  private

  def allow_braintree_iframe
    response.headers['X-Frame-Options'] = 'ALLOW-FROM https://assets.braintreegateway.com'
  end

end
