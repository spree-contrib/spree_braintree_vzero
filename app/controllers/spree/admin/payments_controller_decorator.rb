Spree::Admin::PaymentsController.class_eval do
  def create
    invoke_callbacks(:create, :before)
    @payment ||= @order.payments.build(object_params)
    if @payment.payment_method.source_required? && params[:card].present? and params[:card] != 'new'
      @payment.source = @payment.payment_method.payment_source_class.find_by_id(params[:card])
    end

    begin
      if @payment.save
        invoke_callbacks(:create, :after)
        # Transition order as far as it will go.
        while @order.next; end
        # If "@order.next" didn't trigger payment processing already (e.g. if the order was
        # already complete) then trigger it manually now
        process_payment if @order.completed? && @payment.checkout?
        flash[:success] = flash_message_for(@payment, :successfully_created)
        redirect_to admin_order_payments_path(@order)
      else
        invoke_callbacks(:create, :fails)
        flash[:error] = Spree.t(:payment_could_not_be_created)
        render :new
      end
    rescue Spree::Core::GatewayError => e
      invoke_callbacks(:create, :fails)
      flash[:error] = "#{e.message}"
      fail @payment.inspect
      redirect_to new_admin_order_payment_path(@order)
    end
  end

  private

  def process_payment
    if @payment.payment_source.is_a?(Spree::Gateway::BraintreeVzero)
      result = @payment.payment_source.purchase(params[:payment_method_nonce], @order, nil, object_params[:amount])

      @payment.source = Spree::BraintreeCheckout.create!(transaction_id: result.transaction.id)
      @payment.response_code = result.transaction.id
      @payment.save!
      # separate update for state modification callback
      @payment.source.update(state: result.transaction.status)
    else
      @payment.process!
    end
  end
end
