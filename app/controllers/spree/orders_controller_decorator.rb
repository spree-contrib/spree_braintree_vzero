Spree::OrdersController.class_eval do
  before_filter :process_braintree, only: :update

  def process_braintree
    return true if params[:paypal].blank?
    return true if (nonce = params[:paypal][:payment_method_nonce]).blank?
    payment_method = Spree::PaymentMethod.find_by_id(params[:paypal][:payment_method_id])
    return true unless payment_method

    current_order.save_paypal_address('ship_address', address_params(:ship_address))
    current_order.save_paypal_address('bill_address', address_params(:bill_address))

    result = payment_method.purchase({ payment_method_nonce: nonce }, current_order)

    if result.success?
      payment_method.complete_order(current_order, result, payment_method)
      flash.notice = Spree.t(:order_processed_successfully)
      flash[:order_completed] = true
      session[:order_id] = nil
      redirect_to spree.order_path(current_order)
    else
      flash[:error] = @order.errors.full_messages.join("\n")
      redirect_to checkout_state_path(current_order.state)
    end

  end

  private

  def address_params(key)
    params[:order].require(key).permit(:firstname, :lastname, :zipcode, :city, :address1, :address2, :phone, :full_name, :country, :state)
  end

end
