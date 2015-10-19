Spree::CheckoutController.class_eval do
  after_action :allow_braintree_iframe

  def update_registration
    if params[:order][:email] =~ Devise.email_regexp && current_order.update_attribute(:email, params[:order][:email])
      redirect_back_or_default spree.checkout_path
    else
      flash[:registration_error] = t(:email_is_invalid, :scope => [:errors, :messages])
      @user = Spree::User.new
      render 'registration'
    end
  end

  private

  def allow_braintree_iframe
    response.headers['X-Frame-Options'] = 'ALLOW-FROM https://assets.braintreegateway.com'
  end

end
