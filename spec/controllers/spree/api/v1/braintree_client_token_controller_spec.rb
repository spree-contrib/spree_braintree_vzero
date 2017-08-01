require 'spec_helper'

describe Spree::Api::V1::BraintreeClientTokenController, :vcr, type: :controller do
  let!(:gateway) { create(:vzero_gateway, auto_capture: true) }
  let(:order) { create(:order) }

  describe 'POST #create' do
    context 'guest checkout' do
      it 'returns proper json data when gateway not specified' do
        post :create, params: { order_number: order.number }
        expect(response).to have_http_status 200
        expect(json_response['client_token']).not_to be nil
        expect(json_response['payment_method_id']).not_to be nil
      end

      it 'returns proper json data when gateway specified' do
        post :create, params: { payment_method_id: gateway.id, order_number: order.number }
        expect(response).to have_http_status 200
        expect(json_response['client_token']).not_to be nil
        expect(json_response['payment_method_id']).to eq gateway.id
      end
    end

    context 'user checkout' do
      let!(:user) { create(:user) }
      before { user.generate_spree_api_key! }

      it 'returns proper json data when gateway not specified' do
        post :create, params: { order_number: order.number, token: user.spree_api_key }
        expect(response).to have_http_status 200
        expect(json_response['client_token']).not_to be nil
        expect(json_response['payment_method_id']).not_to be nil
      end

      it 'returns proper json data when gateway specified' do
        post :create, params: {  payment_method_id: gateway.id, token: user.spree_api_key, order_number: order.number }
        expect(response).to have_http_status 200
        expect(json_response['client_token']).not_to be nil
        expect(json_response['payment_method_id']).to eq gateway.id
      end
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
