Spree::Admin::OrdersController.class_eval do

  before_action :load_order, only: :clone

  def clone
      cloner = Spree::OrderDuplicator.new(@order)
    if cloner.clone && cloner.success?
      redirect_to cart_admin_order_path(@order)
    else
      flash[:error] = cloner.cloned_order.errors.full_messages.join("\n")
      redirect_to :back
    end

  end

end