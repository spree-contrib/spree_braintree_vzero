require 'spec_helper'

describe Spree::Address do
  describe '.vaulted_duplicates' do
    subject { described_class.vaulted_duplicates(given_address) }

    let(:given_address) { create(:address) }
    let(:vaulted_duplicate) do
      Spree::Address.create(given_address.attributes.symbolize_keys.except(:id, :updated_at, :created_at, :braintree_id, :preferences).
                                                                    merge(braintree_id: rand(100)))
    end
    let(:some_address) { create(:address) }

    it 'returns only vaulted duplicates of given address' do
      expect(subject).to contain_exactly vaulted_duplicate
    end
  end
end