module Spree
  module Admin
    module PaymentsControllerDecorator
      def create
        invoke_callbacks(:create, :before)
        @payment ||= @order.payments.build(object_params)
        # not only credit card may require source
        if @payment.payment_method.source_required?
          if params[:card].present? && params[:card] != 'new'
            @payment.source = @payment.payment_method.payment_source_class.find_by_id(params[:card])
          elsif @payment.payment_source.is_a?(Spree::Gateway::BraintreeVzeroBase)
            @payment.braintree_token = params[:payment_method_token]
            @payment.braintree_nonce = params[:payment_method_nonce]
            @payment.source = Spree::BraintreeCheckout.create!(admin_payment: true)
          end
        end

        begin
          if @payment.save
            invoke_callbacks(:create, :after)
            # Transition order as far as it will go.
            while @order.next; end
            # If "@order.next" didn't trigger payment processing already (e.g. if the order was
            # already complete) then trigger it manually now
            @payment.process! if @order.completed? && @payment.checkout?
            flash[:success] = flash_message_for(@payment, :successfully_created)
            redirect_to admin_order_payments_path(@order)
          else
            invoke_callbacks(:create, :fails)
            flash[:error] = Spree.t(:payment_could_not_be_created)
            render :new
          end
        rescue Spree::Core::GatewayError => e
          invoke_callbacks(:create, :fails)
          flash[:error] = e.message.to_s
          redirect_to new_admin_order_payment_path(@order)
        end
      end
    end
  end
end

::Spree::Admin::PaymentsController.prepend(Spree::Admin::PaymentsControllerDecorator)
