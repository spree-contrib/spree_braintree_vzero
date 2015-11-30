require 'spec_helper'

describe Spree::Gateway::BraintreeVzeroDropInUI, :vcr do
  subject { create(:vzero_dropin_ui_gateway) }

  describe 'after_save' do
    let(:hosted_fields_gateway) { create(:vzero_hosted_fields_gateway) }

    it 'activation should disable Hosted Fields Gateways' do
      subject.update_column(:active, false)
      expect(hosted_fields_gateway).to be_active
      subject.update(active: true)
      expect(hosted_fields_gateway.reload).to_not be_active
    end

    it 'deactivation should not disable Hosted Fields Gateways' do
      subject
      expect(hosted_fields_gateway).to be_active
      subject.update(active: false)
      expect(hosted_fields_gateway.reload).to be_active
    end

    it 'creation of activated should disable Hosted Fields Gateways' do
      expect(hosted_fields_gateway).to be_active
      subject
      expect(hosted_fields_gateway.reload).to_not be_active
    end

    it 'creation of deactivated should not disable Hosted Fields Gateways' do
      expect(hosted_fields_gateway).to be_active
      create(:vzero_dropin_ui_gateway, active: false)
      expect(hosted_fields_gateway.reload).to be_active
    end
  end
end
