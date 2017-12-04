Spree::Admin::PaymentsController.class_eval do
  create.before :initBraintree

  private
  def initBraintree
    unless @payment_method.store_credit?
      @payment ||= @order.payments.build(object_params)
      if @payment.payment_method.source_required? && @payment.payment_source.is_a?(Spree::Gateway::BraintreeVzeroBase)
        @payment.braintree_token = params[:payment_method_token]
        @payment.braintree_nonce = params[:payment_method_nonce]
        @payment.source = Spree::BraintreeCheckout.create!(admin_payment: true)
      end
    end
  end
end
