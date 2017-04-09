require 'spec_helper'

describe Spree::CheckoutController, :vcr, type: :controller do
  let(:user) { create(:user) }
  let(:order) { OrderWalkthrough.up_to(:payment) }

  before do
    allow(controller).to receive_messages try_spree_current_user: user
    allow(controller).to receive_messages spree_current_user: user
    allow(controller).to receive_messages current_order: order
  end

  context '#update' do
    context 'braintree payment' do
      let(:braintree_payment_method) { create(:vzero_gateway) }
      let(:params) do
        {
          order: {
            payments_attributes: [{
              'payment_method_id' => braintree_payment_method.id,
              'braintree_token' => 'k5jkr6',
              'braintree_nonce' => '4cdec532-b616-41cc-babf-c1d5cfbbe6c2',
              'amount' => 23
            }],
            coupon_code: ''
          },
          device_data: '{\"device_session_id\":\"ce3a962b468a0c912b6cf53f72f154e3\",\"fraud_merchant_id\":\"600000\",\"correlation_id\":\"d61971aadd35b3da938a99902a299be6\"}',
          state: 'payment'
        }
      end

      before do
        allow(order).to receive_messages state: 'payment'
        allow(controller).to receive_messages check_authorization: true
      end

      it 'advanced_fraud_data in source should be updated' do
        expect(order.payments).to be_empty
        put :update, params
        expect(order.reload.payments.last.source.advanced_fraud_data).to eq params[:device_data]
      end

      it 'when nonce, credit card data in source should be updated from params' do
        params[:order][:payments_attributes].first.delete('braintree_token')
        params[:braintree_last_two] = '12'
        put :update, params
        expect(order.reload.payments.last.source.braintree_last_digits).to eq params[:braintree_last_two]
      end

      it 'when token, credit card data in source should be updated from Braintree Vault' do
        token = params[:order][:payments_attributes].first['braintree_token']
        vaulted_payment_method = braintree_payment_method.vaulted_payment_method(token)
        put :update, params
        expect(order.reload.payments.last.source.braintree_last_digits).to eq vaulted_payment_method.last_4
      end

      context 'when user tries to steal other user card' do
        let(:other_user) { create(:user) }
        let!(:card) { create(:credit_card, number: '123456', user: other_user) }

        it 'does not create payment' do
          params[:order].merge!(existing_card: card.id)

          expect(order.payments).to be_empty
          put :update, params
          expect(order.reload.payments).to be_empty
        end
      end
    end

    context 'braintree paypal express payment' do
      before do
        order.payments << create(:braintree_vzero_paypal_payment)
        order.update(state: 'confirm')
        allow(controller).to receive_messages check_authorization: true
      end

      it 'amount in payment should be updated' do
        expect(order.reload.payments.sum(:amount)).to eq 0
        put :update, state: 'confirm'
        expect(order.reload.payments.last.amount).to eq order.total
      end
    end
  end
end
