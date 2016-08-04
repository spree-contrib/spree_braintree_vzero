require 'spec_helper'

describe Spree::OrdersController, type: :controller do
  let(:user) { create(:user) }

  context '#update' do
    let(:order) { OrderWalkthrough.up_to(:delivery) }

    before do
      allow(controller).to receive_messages(try_spree_current_user: user)
      allow(controller).to receive :check_authorization
      allow(controller).to receive_messages current_order: order
    end

    context 'standard checkout for order with braintree paypal express payment' do
      before { order.payments << create(:braintree_vzero_paypal_payment) }

      it 'it should invalidate paypal express payment' do
        expect(order.reload.payments.valid.count).to eq 1
        spree_put :update, {}, order_id: order.id
        expect(order.reload.payments.valid.count).to eq 0
      end
    end
  end
end
