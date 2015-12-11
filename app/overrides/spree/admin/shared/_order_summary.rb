Deface::Override.new(
  virtual_path: 'spree/admin/shared/_order_summary',
  name: 'Add Risk ID & Risk Decision to Order Summary',
  insert_bottom: 'tbody.additional-info',
  text: '<% if @order.paid_with_braintree? %>
          <tr>
            <td data-hook="admin_order_tab_risk_id">
              <strong><%= Spree.t("admin.risk_id") %>:</strong>
            </td>
            <td id="risk_id">
              <%= @order.payments.valid.take.try(:source).try(:risk_id) %>
            </td>
          </tr>
          <tr>
            <td data-hook="admin_order_tab_risk_decision">
              <strong><%= Spree.t("admin.risk_decision") %>:</strong>
            </td>
            <td id="risk_id">
              <%= @order.payments.valid.take.try(:source).try(:risk_decision) %>
            </td>
          </tr>
        <% end %>'
)
