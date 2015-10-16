require 'spec_helper'

describe Spree::Gateway::BraintreeVzeroBase, :vcr do

  context 'valid credentials' do

    let(:gateway) { create(:vzero_gateway, auto_capture: true) }
    let(:order) { OrderWalkthrough.up_to(:payment) }

    it 'generates token without User' do
      expect(gateway.client_token).to_not be_nil
    end

    it 'generates token for new User' do
      expect(gateway.client_token(create(:user))).to_not be_nil
    end

    it 'generates token for User registered in Braintree' do
      user = create(:user, billing_address: create(:address))
      Spree::Gateway::BraintreeVzeroBase::User.new(gateway.provider, user, order).register_user
      expect(gateway.client_token(user)).to_not be_nil
    end

    describe '#purchase' do
      before { gateway.preferred_3dsecure = false }
      let(:other_order) { OrderWalkthrough.up_to(:payment) }

      it 'returns suceess with valid nonce' do
        expect(gateway.purchase({payment_method_nonce: 'fake-valid-nonce'}, order).success?).to be true
      end

      it 'returns false with invalid nonce' do
        expect(gateway.purchase({payment_method_nonce: 'fake-invalid-nonce'}, order).success?).to be false
      end

      it 'does not store Transaction in Vault by default' do
        expect(gateway.purchase({payment_method_nonce: 'fake-valid-nonce'}, order).transaction.credit_card_details.token).to be_nil
      end

      it 'returns success with valid token' do
        gateway.preferred_store_payments_in_vault = :store_all
        token = gateway.purchase({payment_method_nonce: 'fake-valid-nonce'}, order).transaction.credit_card_details.token
        expect(gateway.purchase({payment_method_token: token}, other_order).success?).to be true
      end

      it 'returns false with invalid token' do
        token = 'sometoken'
        expect(gateway.purchase({payment_method_token: token}, other_order).success?).to be false
      end

      context 'with 3DSecure option turned on' do
        before { gateway.preferred_3dsecure = true }

        it 'performs 3DSecure check' do
          expect(gateway.purchase({payment_method_nonce: 'fake-valid-debit-nonce'}, order).success?).to be false
        end

        it 'adds error to Order' do
          gateway.purchase({payment_method_nonce: 'fake-valid-debit-nonce'}, order)
          expect(order.errors.values.flatten.include?(I18n.t(:three_d_secure, scope: 'braintree.error'))).to be true
        end
      end

      context 'using Vault' do
        before { gateway.preferred_store_payments_in_vault = :store_all }

        it 'stores Transaction' do
          card_vault_token = gateway.purchase({payment_method_nonce: 'fake-valid-nonce'}, order).transaction.credit_card_details.token
          expect { Braintree::PaymentMethod.find(card_vault_token) }.not_to raise_error
        end

        it 'saves Braintree::Address id to Spree::Address when address is being saved' do
          gateway.preferred_pass_billing_and_shipping_address = true
          address = create(:address)
          order.update_attribute(:ship_address_id, address.id)
          order.update_attribute(:bill_address_id, address.id)
          gateway.purchase({payment_method_nonce: 'fake-valid-nonce'}, order)

          bill_id = order.billing_address.braintree_id
          ship_id = order.shipping_address.braintree_id
          expect(order.billing_address.braintree_id).to_not be_nil
          expect(order.shipping_address.braintree_id).to_not be_nil
          expect(bill_id).to eq ship_id
        end

        it 'saves unique Braintree::Addresses ids' do
          gateway.preferred_pass_billing_and_shipping_address = true
          order.update_attribute(:ship_address_id, create(:address, first_name: 'foo').id)
          order.update_attribute(:bill_address_id, create(:address, first_name: 'bar').id)
          gateway.purchase({payment_method_nonce: 'fake-valid-nonce'}, order)

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
          order.update_attribute(:ship_address_id, ship_address.id)
          order.update_attribute(:bill_address_id, bill_address.id)

          utils = Spree::Gateway::BraintreeVzeroBase::Utils.new(gateway, order)
          data = gateway.send('set_basic_purchase_data', {}, order, utils)

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
          order.update_attribute(:ship_address_id, old_ship_address.id)
          order.update_attribute(:bill_address_id, old_bill_address.id)
          gateway.purchase({payment_method_nonce: 'fake-valid-nonce'}, order)

          ship_address = create(:address, old_ship_address.attributes.except('id', 'updated_at', 'created_at', 'braintree_id'))
          bill_address = create(:address, old_bill_address.attributes.except('id', 'updated_at', 'created_at', 'braintree_id'))
          other_order.update_attribute(:ship_address_id, ship_address.id)
          other_order.update_attribute(:bill_address_id, bill_address.id)
          user.update(bill_address_id: bill_address.id, ship_address_id: ship_address.id)
          other_order.update(user_id: user.id)

          utils = Spree::Gateway::BraintreeVzeroBase::Utils.new(gateway, other_order)
          data = gateway.send('set_basic_purchase_data', {}, other_order, utils)

          expect(data['billing_address_id']).to eq nil # old_bill_address.reload.braintree_id
          expect(data['shipping_address_id']).to eq nil # old_ship_address.reload.braintree_id
          expect(data['billing']).to eq nil
          expect(data['shipping']).to eq nil
        end

      end

    end

    describe '#admin_purchase' do
      it 'returns success with valid token' do
        gateway.preferred_store_payments_in_vault = :store_all
        token = gateway.purchase({payment_method_nonce: 'fake-valid-nonce'}, order).transaction.credit_card_details.token
        expect(gateway.admin_purchase(token, order, order.total).success?).to be true
      end

      it 'returns false with invalid token' do
        token = 'sometoken'
        expect(gateway.admin_purchase(token, order, order.total).success?).to be false
      end

      it 'creates payment with given amount' do
        amount = 11.21
        gateway.preferred_store_payments_in_vault = :store_all
        token = gateway.purchase({payment_method_nonce: 'fake-valid-nonce'}, order).transaction.credit_card_details.token
        expect(gateway.admin_purchase(token, order, amount).transaction.amount).to eq amount
      end

    end

    describe '#complete_order' do

      before do
        gateway.preferred_3dsecure = false
      end

      context 'with valid nonce' do
        before do
          gateway.complete_order(order, gateway.purchase({payment_method_nonce: 'fake-valid-nonce'}, order), gateway)
        end

        it 'completes order with valid nonce' do
          expect(order.completed?).to be true
        end

        it 'creates Payment object with valid state' do
          expect(order.payments.first.state).to eq 'pending'
        end

        it 'updates Order state' do
          gateway.purchase({payment_method_nonce: 'fake-valid-nonce'}, order)
          expect(order.payment_state).to eq 'balance_due'
        end
      end


      it 'returns false when payment cannot be validated' do
        expect(gateway.complete_order(order, gateway.purchase({payment_method_nonce: 'fake-invalid-nonce'}, order), gateway)).to be false
        expect(order.completed?).to be false
      end

    end

    describe '#update_states' do

      before do
        gateway.preferred_3dsecure = false
        gateway.complete_order(order, gateway.purchase({payment_method_nonce: 'fake-valid-nonce'}, order), gateway)
        order.payments.first.source.update_attribute(:transaction_id, '9drj68') #use already settled transaction
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
      let(:payment) { order.payments.first }
      let(:payment_source) { payment.payment_source }
      let(:void) { gateway.void(payment_source.transaction_id, {}) }
      let!(:prepare_gateway) { gateway.preferred_3dsecure = false }

      context 'with voidable state' do
        let!(:complete_order) do
          gateway.complete_order(order, gateway.purchase({payment_method_nonce: 'fake-valid-nonce'}, order), gateway)
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
        let!(:complete_order) do
          gateway.complete_order(order, gateway.purchase({payment_method_nonce: 'fake-paypal-one-time-nonce'}, order), gateway)
          void
        end

        it 'should not change payment_source state' do
          expect(payment_source.reload.state).to eq 'settling'
        end

        it 'should not change payment_source state' do
          expect(payment.reload.state).to eq 'pending'
        end
      end

    end

    describe '#settle' do

      before do
        gateway.update(auto_capture: false)
        gateway.complete_order(order, gateway.purchase({payment_method_nonce: 'fake-valid-nonce'}, order), gateway)
        @payment = order.payments.first
      end


      context 'settles authorized amount' do

        it 'does not update Order payment_state' do
          expect(order.payment_state).to eq 'balance_due'
          @payment.settle!
          expect(order.reload.payment_state).to eq 'balance_due'
        end

        it 'updates  Payment state' do
          expect(@payment.state).to eq 'pending'
          @payment.settle!
          expect(@payment.state).to eq 'processing'
        end

        it 'submits Transaction for settlement' do
          expect(gateway.provider::Transaction.find(@payment.response_code).status).to eq 'authorized'
          @payment.settle!
          expect(gateway.provider::Transaction.find(@payment.response_code).status).to eq 'submitted_for_settlement'
        end

        it 'prepares Checkout for status updating' do
          @payment.settle!
          expect(Spree::BraintreeCheckout.not_in_state(Spree::BraintreeCheckout::FINAL_STATES).count).to eq 1
        end

      end
    end

    describe '#credit' do
      let(:payment) { order.payments.first }
      let(:payment_source) { payment.payment_source }
      let(:refund) { gateway.credit(1317, payment_source.transaction_id, {}) }
      let!(:prepare_gateway) { gateway.preferred_3dsecure = false }

      context 'with refundable state' do
        let!(:complete_order) do
          gateway.complete_order(order, gateway.purchase({payment_method_nonce: 'fake-paypal-one-time-nonce'}, order), gateway)
        end

        it 'should be a success' do
          expect(refund.success?).to be true
          expect(refund.transaction.amount).to eq 13.17
        end
      end

      context 'with unrefundable state' do
        let!(:complete_order) do
          gateway.complete_order(order, gateway.purchase({payment_method_nonce: 'fake-valid-nonce'}, order), gateway)
        end

        it 'should not be a success' do
          expect(refund.success?).to be false
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
end
