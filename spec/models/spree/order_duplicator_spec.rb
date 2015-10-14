require 'spec_helper'

describe Spree::OrderDuplicator, :vcr do

  let(:gateway) { create(:vzero_gateway, auto_capture: true) }

  shared_examples 'a valid duplicator' do

    it 'duplicates Order' do
      expect(duplicator.cloned_order).to_not be_nil
    end

  end

  context 'without Braintree Payment' do
    let(:order) { OrderWalkthrough.up_to(:payment) }
    let(:duplicator) { Spree::OrderDuplicator.new(order) }


    context 'clones Order' do
      before { duplicator.clone }

      it_behaves_like 'a valid duplicator'

      it 'persists Order totals' do
        expect(order.total).to eq duplicator.cloned_order.total
        expect(order.item_total).to eq duplicator.cloned_order.item_total
        expect(order.shipment_total).to eq duplicator.cloned_order.shipment_total
        expect(order.payment_total).to eq duplicator.cloned_order.payment_total
      end

    end

    context 'and without stock' do

      it 'returs an appropriate error if products are unavailable' do
        stock_item = order.products.first.stock_items.first
        stock_item.update_attribute(:backorderable, false)
        stock_item.set_count_on_hand(0)

        expect {duplicator.clone}.to raise_error(/Quantity selected of/)
      end
    end
  end

  context 'with stored Braintree Payment' do


    let(:order) { OrderWalkthrough.up_to(:payment) }
    let(:duplicator) { Spree::OrderDuplicator.new(order) }

    context 'duplicates Order' do
      before {gateway.preferred_store_payments_in_vault = :store_all}
      before { gateway.complete_order(order, gateway.purchase({payment_method_nonce: 'fake-valid-nonce'}, order), gateway) }
      before { duplicator.clone }


      it_behaves_like 'a valid duplicator'

      it 'creates Braintree Payment with same status as in old one' do
        old_payment_status = Spree::Gateway::BraintreeVzeroBase::Transaction.new(gateway.provider, order.payments.first.source.transaction_id).status
        new_payment_status = Spree::Gateway::BraintreeVzeroBase::Transaction.new(gateway.provider, duplicator.cloned_order.payments.first.source.transaction_id).status
        expect(new_payment_status).to eq old_payment_status
      end

      it 'clones Shipment with same cost' do
        expect(duplicator.cloned_order.shipments.first.cost).to eq order.shipments.first.cost
      end

      it 'raises an appropriate error when Braintree Payment cannot be cloned' do
        order.payments.first.source.update_attribute(:transaction_id, 'foobar')
        expect {duplicator.clone}.to raise_error(Braintree::NotFoundError)
      end

    end

  end

end