Spree::OrdersController.class_eval do
  before_filter :process_paypal_express, only: :update

  def process_paypal_express
    return true if params[:paypal].blank?
    return true if (nonce = params[:paypal][:payment_method_nonce]).blank?
    payment_method = Spree::PaymentMethod.find_by_id(params[:paypal][:payment_method_id])
    return true unless payment_method

    current_order.save_paypal_address('ship_address', address_params(:ship_address))
    current_order.save_paypal_address('bill_address', address_params(:bill_address))

    payment_method.push_order_to_delivery(current_order, params[:order][:email])
    payment_params = {
      payment_method_nonce: nonce,
      payment_method_id: payment_method.id
    }
    redirect_to checkout_state_path(current_order.state, payment_params)
  end

  private

  def address_params(key)
    params[:order].require(key).permit(:firstname, :lastname, :zipcode, :city, :address1, :address2, :phone, :full_name, :country, :state)
  end

end
