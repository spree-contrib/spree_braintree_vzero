Spree::UserSessionsController.class_eval do
  before_action :associate_user, only: :create

  def current_order_params
    { currency: current_currency, guest_token: cookies.signed[:guest_token], store_id: current_store.id }
  end
end
