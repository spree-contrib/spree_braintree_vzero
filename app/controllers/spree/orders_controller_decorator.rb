Spree::OrdersController.class_eval do
  before_filter :process_paypal_express, only: :update

  def process_paypal_express
    return true if params[:paypal].blank?
    return true if (nonce = params[:paypal][:payment_method_nonce]).blank?
    payment_method = Spree::PaymentMethod.find_by_id(params[:paypal][:payment_method_id])
    return true unless payment_method

    email = params[:order][:email]
    current_order.save_paypal_payment(nonce, payment_method.id, email)

    if params[:order][:ship_address].present? && params[:order][:bill_address].present?
      current_order.save_paypal_address('ship_address', address_params(:ship_address))
      current_order.save_paypal_address('bill_address', address_params(:bill_address))
      payment_method.push_order_to_state(current_order, 'delivery', email)
    else
      payment_method.push_order_to_state(current_order, 'address', email)
    end
    redirect_to checkout_state_path(current_order.state, paypal_email: email)
  end

  private

  def address_params(key)
    params[:order].require(key).permit(:firstname, :lastname, :zipcode, :city, :address1, :address2, :phone, :full_name, :country, :state)
  end

end
