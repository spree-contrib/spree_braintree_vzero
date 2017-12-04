Spree::Admin::PaymentsController.class_eval do
  before_action :initBraintree, only: [:create]
  # def create
  #   invoke_callbacks(:create, :before)

  #   begin
  #     if @payment_method.store_credit?
  #       payments = @order.add_store_credit_payments
  #     else
  #       @payment ||= @order.payments.build(object_params)
  #       if @payment.payment_method.source_required? 
  #         if params[:card].present? && params[:card] != 'new'
  #           @payment.source = @payment.payment_method.payment_source_class.find_by(id: params[:card])
  #         elsif @payment.payment_source.is_a?(Spree::Gateway::BraintreeVzeroBase)
  #           @payment.braintree_token = params[:payment_method_token]
  #           @payment.braintree_nonce = params[:payment_method_nonce]
  #           @payment.source = Spree::BraintreeCheckout.create!(admin_payment: true)
  #         end
  #       end
  #       @payment.save
  #       payments = [@payment]
  #     end

  #     if payments && (saved_payments = payments.select &:persisted?).any?
  #       invoke_callbacks(:create, :after)

  #       # Transition order as far as it will go.
  #       while @order.next; end
  #       # If "@order.next" didn't trigger payment processing already (e.g. if the order was
  #       # already complete) then trigger it manually now

  #       saved_payments.each { |payment| payment.process! if payment.reload.checkout? && @order.complete? }
  #       flash[:success] = flash_message_for(saved_payments.first, :successfully_created)
  #       redirect_to admin_order_payments_path(@order)
  #     else
  #       @payment ||= @order.payments.build(object_params)
  #       invoke_callbacks(:create, :fails)
  #       flash[:error] = Spree.t(:payment_could_not_be_created)
  #       render :new
  #     end
  #   rescue Spree::Core::GatewayError => e
  #     invoke_callbacks(:create, :fails)
  #     flash[:error] = e.message.to_s
  #     redirect_to new_admin_order_payment_path(@order)
  #   end
  # end
  private
  def initBraintree
    if @payment.payment_method.source_required? && @payment.payment_source.is_a?(Spree::Gateway::BraintreeVzeroBase)
      @payment.braintree_token = params[:payment_method_token]
      @payment.braintree_nonce = params[:payment_method_nonce]
      @payment.source = Spree::BraintreeCheckout.create!(admin_payment: true)
    end
  end
end
