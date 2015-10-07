require 'spec_helper'

describe Spree::Gateway::BraintreeVzero::Address, :vcr do

  let(:gateway) { create(:vzero_gateway, auto_capture: true) }
  let(:user) { create(:user) }
  let(:order) { create(:order) }
  let(:braintree_address) { Spree::Gateway::BraintreeVzero::Address.new(gateway.provider, order) }

  context '#create' do

    it 'creates Braintree Address' do
      expect(braintree_address.create.address.id).to_not be_nil
    end

    it 'finds Braintree Address' do
      expect(braintree_address.find(braintree_address.create.address)).to_not be_nil
    end

    it 'updates Braintree Address' do
      result = braintree_address.update(braintree_address.create.address, {first_name: 'new_name'})
      expect(result.address.first_name).to eq 'new_name'
    end

    it 'deletes Braintree Address' do
      result = braintree_address.create
      expect(braintree_address.delete(result.address).success?).to be true
    end

  end
end