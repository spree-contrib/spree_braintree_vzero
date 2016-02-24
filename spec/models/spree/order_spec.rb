require 'spec_helper'

describe Spree::Order, :vcr do
  let(:gateway) { create(:vzero_gateway, auto_capture: true) }
  let(:payment) { create(:braintree_vzero_payment, payment_method: gateway) }
  let(:payment_source) { payment.payment_source }
  let(:order) { OrderWalkthrough.up_to(:delivery) }
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

  describe 'checkout steps' do
    it 'should not include confirmation step by default' do
      expect(order.checkout_steps).not_to include 'confirm'
    end

    it 'should include payment step by default' do
      expect(order.checkout_steps).to include 'payment'
    end

    context 'with braintree dropin payment' do
      before { add_payment_to_order! }

      it 'should include confirmation step' do
        order.update(state: 'payment')
        expect(order.confirmation_required?).to be true
      end

      it 'should include payment step' do
        expect(order.checkout_steps).to include 'payment'
      end
    end

    context 'with braintree paypal express payment' do
      let(:gateway) { create(:vzero_paypal_gateway, auto_capture: true) }
      before { add_payment_to_order! }

      it 'should not include confirmation step when payed by paypal express from cart' do
        order.update(state: 'delivery')
        expect(order.confirmation_required?).to be false
      end

      it 'should include confirmation step when payed by paypal express from payment step' do
        order.update(state: 'payment')
        expect(order.confirmation_required?).to be true
      end

      it 'should not include payment step' do
        expect(order.checkout_steps).not_to include 'payment'
      end
    end
  end

  describe 'addresses managment' do
    let(:country) { create(:country, name: 'Poland', iso: 'PL') }
    let(:state) { create(:state, name: 'Mazowieckie', abbr: 'MZ', country: country) }

    context 'paypal addresses' do
      let(:type) { 'ship_address' }
      let(:attr) { address_hash.except(:full_name, :country, :state).keys.map(&:to_s) }
      let(:address_hash) do
        {
          zipcode: '02-796',
          city: 'Warsaw',
          address1: 'gder 1/7',
          address2: '13b',
          phone: '408-391-8922',
          full_name: 'Test ree ree Acd',
          country: 'PL',
          state: 'MZ'
        }.with_indifferent_access
      end

      let(:prepare_data) do
        order
        state
      end

      let(:save_paypal_address!) do
        prepare_data
        expect(order.ship_address.attributes.slice(*attr)).not_to match address_hash.slice(*attr)
        order.save_paypal_address(type, address_hash.dup)
      end

      shared_examples 'comparable' do
        it 'should save basic address data without changes' do
          expect(order.reload.ship_address.attributes.slice(*attr)).to match address_hash.slice(*attr)
        end

        it 'should find and set proper country' do
          expect(order.reload.ship_address.country.iso).to eq address_hash[:country]
        end

        it 'should split name in proper way' do
          name_array = address_hash[:full_name].split(' ')
          last = name_array.slice!(-1)
          first = name_array.join(' ')
          expect(order.reload.ship_address.firstname).to eq first
          expect(order.reload.ship_address.lastname).to eq last
        end
      end

      context 'with state as abbreviation' do
        before do
          save_paypal_address!
        end

        include_examples 'comparable'

        it 'should find and set proper state' do
          expect(order.reload.ship_address.state.abbr).to eq address_hash[:state]
        end
      end

      context 'with state as name' do
        before do
          address_hash.merge!(state: 'MAZOWIECKIE')
          save_paypal_address!
        end

        include_examples 'comparable'

        it 'should find and set proper state' do
          expect(order.reload.ship_address.state.name).to eq address_hash[:state].capitalize
        end
      end

      it 'should not include fields with text "undefined"' do
        address_hash.merge!(address2: 'undefined')
        save_paypal_address!
        expect(order.reload.ship_address.address2).to eq nil
      end

      context 'billing address from shipping_address' do
        it 'should be set when empty' do
          order.update_column(:bill_address_id, nil)
          order.set_billing_address
          expect(order.reload.bill_address.attributes.slice(*attr)).to match order.ship_address.attributes.slice(*attr)
        end

        it 'should not be set when exists' do
          order.set_billing_address
          expect(order.reload.bill_address.attributes.slice(*attr)).not_to match address_hash.slice(*attr)
        end
      end
    end
  end
end
