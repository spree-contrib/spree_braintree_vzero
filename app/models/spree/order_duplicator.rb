module Spree
  class OrderDuplicator

    include ActiveModel::Validations

    attr_accessor :order, :cloned_order

    def initialize(order)
      @order = order
    end

    def clone

      Spree::Order.transaction do
        new_order = Spree::Order.new(
          user_id: order.user_id,
          email: order.email,
          shipping_address: order.shipping_address,
          billing_address: order.billing_address
        )
        new_order.generate_number

        @cloned_order = new_order

        check_products_availability
        order.line_items.each { |li| cloned_order.contents.add(li.variant, li.quantity) }
        create_shipment
        create_braintree_payment

        raise ActiveRecord::Rollback if cloned_order.errors.any?

        cloned_order.update_attributes(order.attributes.except('id', 'number', 'created_at', 'updated_at', 'channel', 'guest_token').merge!(channel: 'clone'))
      end
      cloned_order
    end

    def success?
      cloned_order && cloned_order.errors.empty?
    end

    private

    def create_shipment
      cloned_order.create_proposed_shipments
      cloned_order.refresh_shipment_rates

      shipment = order.shipments.first
      cloned_order.shipments.each {|s|s.update_attributes(cost: shipment.cost, state: shipment.state, selected_shipping_rate_id: s.shipping_rates.detect {|x| x.shipping_method_id == shipment.selected_shipping_rate.shipping_method.id} ) }
      order.all_adjustments.each do |a|
        new_adjustment = cloned_order.adjustments.create(a.dup)
        new_adjustment.source = a.source
        new_adjustment.save
      end
    end

    def check_products_availability
      order.line_items.map { |line_item| line_item.variant.can_supply?(line_item.quantity) ? true : cloned_order.errors.add(:base, Spree.t(:product_unavailable, product: line_item.name, scope: :admin)) }
    end

    def create_braintree_payment
      gateway = Gateway::BraintreeVzeroStandard.first
      clones = []
      order.payments.each do |payment|
        next unless payment.source.is_a? Spree::BraintreeCheckout
        result = Gateway::BraintreeVzeroBase::Transaction.new(gateway.provider, payment.source.transaction_id).clone
        clones << result
        if result.success?
          gateway.complete_order(cloned_order, result, payment.payment_method)
        end
      end

      cloned_order.errors.add(:base, Spree.t(:cannot_clone_payment, scope: :admin)) unless clones.all?(&:success?)
      
      clones
    end

  end
end