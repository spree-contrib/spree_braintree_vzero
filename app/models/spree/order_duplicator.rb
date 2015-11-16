module Spree
  class OrderDuplicator

    include ActiveModel::Validations

    attr_accessor :order, :cloned_order

    def initialize(order)
      @order = order
    end

    def clone
      Spree::Order.transaction do
        create_basic_data_order
        create_order_content
        create_shipments
        create_adjustments
        create_braintree_payment

        fail ActiveRecord::Rollback if cloned_order.errors.any?

      end
      cloned_order
    end

    def success?
      cloned_order && cloned_order.errors.empty?
    end

    private

    def create_basic_data_order
      @cloned_order = Spree::Order.create!(
        user_id: order.user_id,
        email: order.email,
        state: 'confirm',
        shipping_address: order.shipping_address,
        billing_address: order.billing_address
      )
    end

    def create_order_content
      check_products_availability
      order.line_items.each { |li| cloned_order.contents.add(li.variant, li.quantity) }
    end

    def create_shipments
      cloned_order.create_proposed_shipments
      cloned_order.refresh_shipment_rates

      shipment = order.shipments.first
      cloned_order.shipments.each do |s|
        s.update_attributes(
          cost: shipment.cost,
          state: shipment.state,
          selected_shipping_rate_id: s.shipping_rates.detect { |x| x.shipping_method_id == shipment.selected_shipping_rate.shipping_method.id }
        )
      end
    end

    def create_adjustments
      order.all_adjustments.each do |a|
        adjustment_data = a.attributes
        new_adjustment = cloned_order.adjustments.create(adjustment_data.slice('amount', 'label', 'eligible', 'state', 'included').merge(order_id: cloned_order.id))
        new_adjustment.source = a.source
        if a.is_a?(Spree::LineItem)
          new_adjustment.adjustable = cloned_order.line_items.find_by(adjustment_data.slice('variant_id', 'quantity'))
        else
          new_adjustment.adjustable = a.adjustable
        end
        new_adjustment.mandatory = a.eligible
        new_adjustment.save
      end

      cloned_order.update!
    end

    def check_products_availability
      order.line_items.map { |line_item| line_item.variant.can_supply?(line_item.quantity) ? true : cloned_order.errors.add(:base, Spree.t(:product_unavailable, product: line_item.name, scope: :admin)) }
    end

    def create_braintree_payment
      order.payments.valid.each do |payment|
        gateway = payment.payment_method
        next unless gateway.kind_of? Spree::Gateway::BraintreeVzeroBase
        transaction = Spree::Gateway::BraintreeVzeroBase::Transaction.new(gateway.provider, payment.source.transaction_id)
        source = Spree::BraintreeCheckout.create!
        next unless (token = transaction.token) # unvaulted payment
        cloned_order.payments.create!(payment.attributes.slice('amount', 'payment_method_id').merge(state: 'checkout', source: source, braintree_token: token, order_id: cloned_order.id))
      end

      unless cloned_order.payments.valid.any?
        cloned_order.errors.add(:base, Spree.t(:cannot_clone_payment, scope: :admin))
        return
      end
      cloned_order.next!
    end
  end
end
