require 'spec_helper'

describe Spree::Order, :vcr do
  let(:gateway) { create(:vzero_gateway, auto_capture: true) }
  let(:payment) { create(:braintree_vzero_payment, payment_method: gateway) }
  let(:payment_source) { payment.payment_source }
  let(:order) { OrderWalkthrough.up_to(:payment) }
  let(:add_payment_to_order!) { order.payments << payment }

  describe 'complete with braintree vzero standard payment' do
    let!(:complete_order!) do
      add_payment_to_order!
      2.times { order.next! }
    end

    context 'with auto_capture' do
      it 'should complete payment' do
        expect(payment.reload.state).to eq 'completed'
      end

      it "should update payment's response_code" do
        expect(payment.reload.response_code).not_to be_blank
      end

      it "should update payment's source state and transaction_id" do
        expect(payment.reload.source.state).to eq 'submitted_for_settlement'
        expect(payment.reload.source.transaction_id).not_to be_blank
      end
    end

    context 'without auto_capture' do
      let(:gateway) { create(:vzero_gateway, auto_capture: false) }

      it 'should pend payment' do
        expect(payment.reload.state).to eq 'pending'
      end

      it "should update payment's response_code" do
        expect(payment.reload.response_code).not_to be_blank
      end

      it "should update payment's source state and transaction_id" do
        expect(payment.reload.source.state).to eq 'authorized'
        expect(payment.reload.source.transaction_id).not_to be_blank
      end
    end
  end

end
