Spree::CheckoutController.class_eval do

  before_filter :process_braintree, only: :update
  after_action :allow_braintree_iframe

  def process_braintree
    return true if params[:order][:payments_attributes].blank?
    payment_method = Spree::PaymentMethod.find_by_id(params[:order][:payments_attributes].first[:payment_method_id])

    if payment_method && payment_method.kind_of?(Spree::Gateway::BraintreeVzeroBase)
      result = if (token = params[:payment_method_token]).present?
                 payment_method.purchase({payment_method_token: token}, current_order, params[:device_data])
               elsif (nonce = params[:payment_method_nonce]).present?
                 payment_method.purchase({payment_method_nonce: nonce}, current_order, params[:device_data])
               end

      if result.success?
        payment_method.complete_order(current_order, result, payment_method)
        flash.notice = Spree.t(:order_processed_successfully)
        flash[:order_completed] = true
        session[:order_id] = nil
        redirect_to completion_route(current_order)
      else
        flash[:error] = @order.errors.full_messages.join("\n")
        redirect_to checkout_state_path(current_order.state)
      end
    end

  end

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
