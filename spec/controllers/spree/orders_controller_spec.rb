require 'spec_helper'

describe Spree::OrdersController, type: :controller do
  let(:user) { create(:user) }
  let!(:country) { create(:country, iso: 'US') }
  let!(:state) { create(:state, country: country) }

  context '#update' do
    let(:order) { OrderWalkthrough.up_to(:payment) }

    before do
      allow(controller).to receive_messages(try_spree_current_user: user)
      allow(controller).to receive :check_authorization
      allow(controller).to receive_messages current_order: order
    end

    context 'standard checkout for order with braintree paypal express payment' do
      before { order.payments << create(:braintree_vzero_paypal_payment) }

      it 'it should invalidate paypal express payment' do
        expect(order.reload.payments.valid.count).to eq 1
        put :update, params: { order_id: order.id }
        expect(order.reload.payments.valid.count).to eq 0
      end
    end

    context 'paypal express checkout' do
      let(:payment_method) { create(:vzero_paypal_gateway) }
      let(:params) do
        {
          order_id: order.id,
          order: {
            line_items_attributes: {
              '0' => {
                quantity: '1',
                id: '127'
              }
            },
            ship_address: {
              zipcode: '95131',
              full_name: 'undefined',
              firstname: 'Spree',
              lastname: 'Buyer',
              address1: '1 Main St',
              address2: 'undefined',
              city: 'San Jose',
              country: 'US',
              state: Spree::State.first.abbr
            },
            email: 'spree_buyer@spreetest.com'
          },
          paypal: {
            payment_method_id: payment_method.id.to_s,
            payment_method_nonce: '2f7126df-ceee-40a6-a7b4-ab1b799810f3'
          },
          device_data: '{\"device_session_id\":\"4523fd012467562ec455926850f7ce11\",\"fraud_merchant_id\":\"600000\"}',
          checkout: 'true'
        }
      end

      it 'it should save address both as billing and shipping (even when phone number is not passed)' do
        put :update, params: params
        data = params.slice(:order)[:order].slice(:ship_address)[:ship_address]
        [order.ship_address, order.bill_address].each do |address|
          expect(address.zipcode).to eq data[:zipcode]
          expect(address.firstname).to eq data[:firstname]
          expect(address.lastname).to eq data[:lastname]
          expect(address.address1).to eq data[:address1]
          expect(address.address2).to be_blank
          expect(address.city).to eq data[:city]
          expect(address.country.iso).to eq data[:country]
          expect(address.state.abbr).to eq data[:state]
          expect(address.phone).to be_blank
        end
      end

      it 'it should redirect to address page when address is invalid' do
        put :update, params: params

        [order.ship_address, order.bill_address].each do |address|
          expect(address).to be_invalid
        end
        expect(response).to redirect_to checkout_state_path(:address, paypal_email: params[:order][:email])
      end

      it 'it should redirect to address page when address is valid' do
        params[:order][:ship_address][:phone] = '123456789'
        put :update, params: params

        [order.ship_address, order.bill_address].each do |address|
          expect(address).to be_valid
        end
        expect(response).to redirect_to checkout_state_path(:address, paypal_email: params[:order][:email])
      end
    end
  end
end
