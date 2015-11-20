require 'spec_helper'

describe Spree::Adjustment, :vcr do
  subject { create(:adjustment, order: create(:order)) }

  it 'should set eligible on true when mandatory is true' do
    subject.update_columns(mandatory: true, eligible: false)

    expect(subject.eligible).to be false
    subject.save!
    expect(subject.eligible).to be true
  end
end
