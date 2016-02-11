require 'spec_helper'

describe Spree::Gateway::BraintreeVzeroBase::PurchaseData do
  let(:gateway) { create(:vzero_gateway, auto_capture: true) }
  let(:payment) { create(:braintree_vzero_payment, payment_method: gateway) }
  let(:payment_source) { payment.payment_source }
  let(:order) { OrderWalkthrough.up_to(:payment) }

  before do
    gateway.preferred_3dsecure = true
    payment.update(braintree_nonce: 'fake-valid-debit-nonce')
    gateway.preferred_advanced_fraud_tools = true
    payment.source.update(advanced_fraud_data: '{\"device_session_id\":\"5a0c416f74a6044e4693204b4373b9e1\",\"fraud_merchant_id\":\"abcc\"}')
    gateway.instance_variable_set(:@utils, utils)
  end

  context 'data from admin panel' do
    let(:identifier_hash) { { payment_method_nonce: '123' } }
    let(:utils) { Spree::Gateway::BraintreeVzeroBase::Utils.new(gateway, order) }
    let(:set_data) { gateway.send(:set_purchase_data, identifier_hash, order, 113, payment_source) }

    before { payment_source.update(admin_payment: true) }

    it 'should include only essential data' do
      data = set_data
      expect(data[:payment_method_nonce]).to eq identifier_hash[:payment_method_nonce]
      expect(data[:channel]).to eq 'SpreeCommerceInc_Cart_Braintree'
      expect(data[:device_data]).to be_blank
      expect(data[:options][:three_d_secure][:required]).to be_blank
    end
  end

  context 'data from checkout' do
    let(:identifier_hash) { { payment_method_nonce: '123' } }
    let(:utils) { Spree::Gateway::BraintreeVzeroBase::Utils.new(gateway, order) }
    let(:set_data) { gateway.send(:set_purchase_data, identifier_hash, order, 113, payment_source) }

    it 'should include all data' do
      data = set_data
      expect(data[:payment_method_nonce]).to eq identifier_hash[:payment_method_nonce]
      expect(data[:channel]).to eq 'SpreeCommerceInc_Cart_Braintree'
      expect(data[:device_data]).to eq payment.source.advanced_fraud_data
      expect(data[:options][:three_d_secure][:required]).to be true
    end
  end
end
