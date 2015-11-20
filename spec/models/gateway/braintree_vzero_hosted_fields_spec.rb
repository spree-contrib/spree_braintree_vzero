require 'spec_helper'

describe Spree::Gateway::BraintreeVzeroHostedFields, :vcr do
  subject { create(:vzero_hosted_fields_gateway) }

  describe 'after_save' do
    let(:dropin_ui_gateway) { create(:vzero_dropin_ui_gateway) }

    it 'activation should disable DropIn UI Gateways' do
      subject.update_column(:active, false)
      expect(dropin_ui_gateway.active?).to be true
      subject.update(active: true)
      expect(dropin_ui_gateway.reload.active?).to be false
    end

    it 'deactivation should not disable DropIn UI Gateways' do
      subject
      expect(dropin_ui_gateway.active?).to be true
      subject.update(active: false)
      expect(dropin_ui_gateway.reload.active?).to be true
    end

    it 'creation of activated should disable DropIn UI Gateways' do
      expect(dropin_ui_gateway.active?).to be true
      subject
      expect(dropin_ui_gateway.reload.active?).to be false
    end

    it 'creation of deactivated should not disable DropIn UI Gateways' do
      expect(dropin_ui_gateway.active?).to be true
      create(:vzero_dropin_ui_gateway, active: false)
      expect(dropin_ui_gateway.reload.active?).to be true
    end
  end
end
