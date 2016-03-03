container: "paypal-container",
singleUse: <%= payment_method.preferred_store_payments_in_vault.eql?('do_not_store') %>,
amount: <%= @order.total %>,
currency: "<%= current_currency %>",
locale: "en_us",
displayName: "<%= payment_method.preferred_paypal_display_name %>",
enableShippingAddress: true,
shippingAddressOverride: {
  recipientName: '<%= "#{shipping_address.firstname} #{shipping_address.lastname}" %>',
  streetAddress: '<%= shipping_address.address1 %>',
  extendedAddress: '<%= shipping_address.address2 %>',
  locality: '<%= shipping_address.city %>',
  countryCodeAlpha2: '<%= shipping_address.country.try(:iso) %>',
  postalCode: '<%= shipping_address.zipcode %>',
  region: '<%= shipping_address.state.try(:abbr) %>',
  phone: '<%= shipping_address.phone %>',
  editable: false
},

onReady: function (integration) {
  if(!SpreeBraintreeVzero.admin)
    SpreeBraintreeVzero.deviceData = integration.deviceData;
  checkout = integration;
},
headless: true,

onPaymentMethodReceived: function (result) {
  var formId = "#" + checkoutFormId;

  if (result.nonce.length) {
    $(formId).append("<input type='hidden' name='order[payments_attributes][][braintree_nonce]' value=" + result.nonce + ">");
    $(formId).append("<input type='hidden' name='paypal_email' value=" + result.details.email + ">");
    paymentMethodSelect = $("#order_payments_attributes__braintree_token")
    if(paymentMethodSelect.length) paymentMethodSelect.val("");
    $(formId)[0].submit();
  } else {
    $(errorMessagesContainer).prepend("<div class='alert alert-error'><%= I18n.t(:gateway_error, scope: 'braintree.error') %>></div>")
  }
}
