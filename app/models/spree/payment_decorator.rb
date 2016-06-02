Spree::Payment.class_eval do
  def update_order
    # without reload order was updated with inaccurate data
    order.reload
    if completed? || void?
      order.updater.update_payment_total
    end

    if order.completed?
      order.updater.update_payment_state
      order.updater.update_shipments
      order.updater.update_shipment_state
    end

    if self.completed? || order.completed?
      order.persist_totals
    end
  end
end
