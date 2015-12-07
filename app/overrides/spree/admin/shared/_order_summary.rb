Deface::Override.new(
  virtual_path: 'spree/admin/shared/_order_summary',
  name: 'Add Risk ID & Risk Decision to Order Summary',
  insert_bottom: '.additional-info',
  text: '<% if @order.paid_with_braintree? %>
          <dt data-hook="admin_order_tab_risk_id">
            <strong><%= Spree.t("admin.risk_id") %>:</strong>
          </dt>
          <dd id="risk_id">
            <%= @order.payments.valid.take.try(:source).risk_id %>
          </dd>
          <dt data-hook="admin_order_tab_risk_decision">
            <strong><%= Spree.t("admin.risk_decision") %>:</strong>
          </dt>
          <dd id="risk_decision">
            <%= @order.payments.valid.take.try(:source).risk_decision %>
          </dd>
        <% end %>'
)
