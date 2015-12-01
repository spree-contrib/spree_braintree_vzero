Spree::OrdersHelper.class_eval do
  def options_from_braintree_payments(payment_methods, selected = nil)
    payment_methods.map do |method|
      text = if method.is_a?(Braintree::CreditCard)
               Spree.t('admin.vaulted_payments.credit_card', card_type: method.card_type, last_4: method.last_4)
             elsif method.is_a?(Braintree::PayPalAccount)
               Spree.t('admin.vaulted_payments.paypal', email: method.email)
             end
             "<option value='#{method.token}'>#{text}</option>"
    end.join.html_safe
  end
end
