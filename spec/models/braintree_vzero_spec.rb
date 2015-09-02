require 'spec_helper'

describe Spree::Gateway::BraintreeVzero, :vcr do

  context 'valid credentials' do
    let(:gateway) { create(:vzero_gateway) }

    it 'generates token' do
      expect(gateway.client_token).to_not be_nil
    end

  end

  context 'with invalid credentials' do
    let(:gateway) { create(:vzero_gateway, merchant_id: 'invalid_id') }

    it 'raises Braintree error' do
      expect { gateway.client_token }.to raise_error('Braintree::AuthenticationError')
    end

  end
end