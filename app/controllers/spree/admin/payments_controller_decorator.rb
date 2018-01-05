Spree::Admin::PaymentsController.class_eval do
  create.before :init_braintree

  private
  
  def init_braintree
    return if @payment_method.store_credit?
    @payment ||= @order.payments.build(object_params)
    if braintree_source?(@payment)
      @payment.braintree_token = params[:payment_method_token]
      @payment.braintree_nonce = params[:payment_method_nonce]
      @payment.source = Spree::BraintreeCheckout.create!(admin_payment: true)
    end
  end

  def braintree_source?(payment)
    return payment.payment_method.source_required? && 
          payment.payment_source.is_a?(Spree::Gateway::BraintreeVzeroBase)
  end
end
