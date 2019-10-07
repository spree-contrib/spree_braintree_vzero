require 'spec_helper'

describe Spree::Gateway::BraintreeVzeroBase, :vcr do
  context 'valid credentials' do
    let(:gateway) { create(:vzero_gateway, auto_capture: true) }
    let(:payment) { create(:braintree_vzero_payment, payment_method: gateway) }
    let(:payment_source) { payment.payment_source }
    let(:order) { OrderWalkthrough.up_to(:payment) }
    let(:add_payment_to_order!) { order.payments << payment }
    let(:complete_order!) do
      add_payment_to_order!
      until order.completed? do order.next! end
    end

    it 'generates token without User' do
      expect(gateway.client_token).to_not be_nil
    end

    it 'generates token for new User' do
      expect(gateway.client_token(order, create(:user))).to_not be_nil
    end

    it 'generates token for User registered in Braintree' do
      user = create(:user, billing_address: create(:address))
      Spree::Gateway::BraintreeVzeroBase::BraintreeUser.new(gateway.provider, user, order).register_user
      expect(gateway.client_token(order, user)).to_not be_nil
    end

    describe '#purchase' do
      let(:gateway_options) { { order_id: "#{order.number}-#{payment.number}" } }
      let(:purchase) { gateway.purchase(10_000, payment_source, gateway_options) }
      let(:other_order) { OrderWalkthrough.up_to(:payment) }

      before do
        gateway.preferred_3dsecure = false
        add_payment_to_order!
      end

      it 'returns suceess with valid nonce' do
        expect(purchase.success?).to be true
      end

      it 'returns false with invalid nonce' do
        payment.update(braintree_nonce: 'fake-invalid-nonce')
        expect(purchase.success?).to be false
      end

      it 'does not store Transaction in Vault by default' do
        expect(purchase.transaction.credit_card_details.token).to be_nil
      end

      it 'returns success with valid token' do
        gateway.preferred_store_payments_in_vault = :store_all
        token = purchase.transaction.credit_card_details.token
        payment.update(braintree_token: token)

        expect(purchase.success?).to be true
      end

      it 'returns false when neither nonce nor token is present' do
        payment.update(braintree_nonce: nil, braintree_token: nil)
        expect(purchase.success?).to be false
      end

      it 'returns false with invalid token' do
        token = 'sometoken'
        payment.update(braintree_token: token)
        expect(purchase.success?).to be false
      end

      context 'with advanced fraud tool enabled' do
        before do
          gateway.preferences[:advanced_fraud_data] = true
          payment_source = create(:braintree_checkout_with_fraud_data)
        end

        it 'returns success' do
          expect(purchase).to be_success
        end

        it 'returns fraud data' do
          risk_data = purchase.transaction.risk_data
          expect(risk_data.id.present? && risk_data.decision.present?).to be true
        end
      end

      context 'with 3DSecure option turned on' do
        before do
          gateway.preferred_3dsecure = true
          payment.update(braintree_nonce: 'fake-valid-debit-nonce')
        end

        it 'performs 3DSecure check' do
          expect(purchase.success?).to be false
        end

        it 'returns error' do
          response = purchase
          expect(response.errors.size.zero?).to be true
          expect(response.transaction.try(:gateway_rejection_reason)).to eq 'three_d_secure'
        end
      end

      context 'using Vault' do
        let(:user) { create(:user) }
        before do
          order.user = user
          gateway.preferred_store_payments_in_vault = :store_all
        end

        it 'stores Transaction' do
          card_vault_token = purchase.transaction.credit_card_details.token
          expect { Braintree::PaymentMethod.find(card_vault_token) }.not_to raise_error
        end

        it 'saves Braintree::Address id to Spree::Address when address is being saved' do
          gateway.preferred_pass_billing_and_shipping_address = true
          address = create(:address)
          order.ship_address = address
          order.bill_address = address
          order.save
          purchase
          order.reload

          bill_id = order.billing_address.braintree_id
          ship_id = order.shipping_address.braintree_id
          expect(order.billing_address.braintree_id).to_not be_nil
          expect(order.shipping_address.braintree_id).to_not be_nil
          expect(bill_id).to eq ship_id
        end

        it 'saves unique Braintree::Addresses ids' do
          gateway.preferred_pass_billing_and_shipping_address = true
          ship_address = create(:address, first_name: 'foo')
          bill_address = create(:address, first_name: 'bar')
          order.ship_address = ship_address
          order.bill_address = bill_address
          order.save
          purchase
          order.reload

          bill_id = order.billing_address.braintree_id
          ship_id = order.shipping_address.braintree_id
          expect(bill_id).to_not be_nil
          expect(ship_id).to_not be_nil
          expect(bill_id).to_not eq ship_id
        end

        it 'sends address data when address is new' do
          gateway.preferred_pass_billing_and_shipping_address = true
          ship_address = create(:address, first_name: 'foo')
          bill_address = create(:address, first_name: 'bar')
          order.ship_address = ship_address
          order.bill_address = bill_address
          order.save

          utils = Spree::Gateway::BraintreeVzeroBase::Utils.new(gateway, order)
          data = gateway.send('set_basic_purchase_data', {}, order, utils, order.total * 100)

          expect(data['billing'][:first_name]).to eq bill_address.first_name
          expect(data['shipping'][:first_name]).to eq ship_address.first_name
          expect(data['billing_address_id']).to eq nil
          expect(data['shipping_address_id']).to eq nil
        end

        it 'sends empty address id when address is already in vault' do
          gateway.preferred_pass_billing_and_shipping_address = true
          old_bill_address = create(:address, first_name: 'bar')
          old_ship_address = create(:address, first_name: 'foo')
          user = create(:user, bill_address_id: old_bill_address.id, ship_address_id: old_ship_address.id)
          order.update(user_id: user.id)
          order.ship_address = old_ship_address
          order.bill_address = old_bill_address
          order.save
          purchase

          ship_address = create(:address, old_ship_address.attributes.except('id', 'updated_at', 'created_at', 'braintree_id'))
          bill_address = create(:address, old_bill_address.attributes.except('id', 'updated_at', 'created_at', 'braintree_id'))
          other_order.ship_address = ship_address
          other_order.bill_address = bill_address
          other_order.save
          user.update(bill_address_id: bill_address.id, ship_address_id: ship_address.id)
          other_order.update(user_id: user.id)

          utils = Spree::Gateway::BraintreeVzeroBase::Utils.new(gateway, other_order)
          data = gateway.send('set_basic_purchase_data', {}, other_order, utils, other_order.total * 100)

          expect(data['billing_address_id']).to eq old_bill_address.reload.braintree_id
          expect(data['shipping_address_id']).to eq old_ship_address.reload.braintree_id
          expect(data['billing']).to eq nil
          expect(data['shipping']).to eq nil
        end
      end
    end

    describe '#update_states' do
      before do
        gateway.preferred_3dsecure = false
        payment.update(amount: order.reload.total)
        complete_order!
        order.payments.first.source.update_attribute(:transaction_id, 'dw49zp') # use already settled transaction
      end

      let!(:result) { Spree::BraintreeCheckout.update_states }

      it 'updates payment State' do
        expect(result[:changed]).to eq 1
      end

      it 'does not update completed Checkout on subsequent runs' do
        expect(result[:changed]).to eq 1
        expect(Spree::BraintreeCheckout.update_states[:changed]).to eq 0
      end

      it 'updates Order payment_state when Checkout is updated' do
        expect(order.reload.payment_state).to eq 'paid'
      end

      it 'updates Payment state when Checkout is updated' do
        expect(order.reload.payments.first.state).to eq 'completed'
      end
    end

    describe '#void' do
      let(:void) { gateway.void(payment_source.reload.transaction_id, {}) }
      let!(:prepare_gateway) { gateway.preferred_3dsecure = false }

      context 'with voidable state' do
        before do
          complete_order!
          void
        end

        it 'should change payment_source state to voided' do
          expect(payment_source.reload.state).to eq 'voided'
        end

        it 'should change payment_source state to voided' do
          expect(payment.reload.state).to eq 'void'
        end
      end

      context 'with unvoidable state' do
        before do
          payment.update(braintree_nonce: 'fake-paypal-one-time-nonce')
          complete_order!
          void
        end

        it 'should not change payment_source state' do
          expect(payment_source.reload.state).to eq 'settling'
        end

        it 'should not change payment_source state' do
          expect(payment.reload.state).to eq 'completed'
        end
      end
    end

    describe '#settle' do
      before do
        gateway.update(auto_capture: false)
        complete_order!
        payment.reload
      end

      context 'settles authorized amount' do
        it 'does not update Order payment_state' do
          expect(order.payment_state).to eq 'balance_due'
          payment.reload.settle!
          expect(order.reload.payment_state).to eq 'balance_due'
        end

        it 'updates Payment state' do
          expect(payment.state).to eq 'pending'
          payment.reload.settle!
          expect(payment.state).to eq 'processing'
        end

        it 'submits Transaction for settlement' do
          expect(gateway.provider::Transaction.find(payment.response_code).status).to eq 'authorized'
          payment.reload.settle!
          expect(gateway.provider::Transaction.find(payment.response_code).status).to eq 'submitted_for_settlement'
        end

        it 'prepares Checkout for status updating' do
          payment.reload.settle!
          expect(Spree::BraintreeCheckout.not_in_state(Spree::BraintreeCheckout::FINAL_STATES).count).to eq 1
        end
      end
    end

    describe '#capture' do
      # for Spree::Config.auto_capture_on_dispatch = true

      before do
        gateway.update(auto_capture: false)
        complete_order!
        payment.reload
      end

      context 'captures authorized amount' do
        it 'updates Payment state' do
          expect(payment).to be_pending
          payment.reload.capture!
          expect(payment).to be_completed
        end
      end
    end

    describe '#credit' do
      let(:refund) { gateway.credit(1317, payment_source.reload.transaction_id, {}) }
      let!(:prepare_gateway) { gateway.preferred_3dsecure = false }

      context 'with refundable state' do
        before do
          payment.update(braintree_nonce: 'fake-paypal-one-time-nonce')
          complete_order!
        end

        it 'should be a success' do
          expect(refund.success?).to be true
          expect(refund.transaction.amount).to eq 13.17
        end
      end

      context 'with unrefundable state' do
        before do
          complete_order!
        end

        it 'should not be a success' do
          expect(refund.success?).to be false
        end
      end
    end
  end

  context 'with invalid credentials' do
    let(:gateway) { create(:vzero_gateway, merchant_id: 'invalid_id') }

    it 'raises Braintree error' do
      expect { gateway.client_token }.to raise_error('Braintree::AuthenticationError')
    end
  end
end
