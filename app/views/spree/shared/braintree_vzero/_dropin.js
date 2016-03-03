container: container,
paypal: {
  singleUse: <%= payment_method.preferred_store_payments_in_vault.eql?('do_not_store') %>,
  amount: <%= @order.total %>,
  currency: "<%= current_currency %>",
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
  }
},

onPaymentMethodReceived: function (result) {
  var formId = "#" + checkoutFormId;

  function submitWithAttributes(data) {
    switch (data.type) {
      case "CreditCard":
        $(formId).append("<input type='hidden' name='braintree_last_two' value=" + result.details.lastTwo + ">");
        $(formId).append("<input type='hidden' name='braintree_card_type' value=" + result.details.cardType.replace(/\s/g, "") + ">");
        break;
      case "PayPalAccount":
        $(formId).append("<input type='hidden' name='paypal_email' value=" + (result.details.email)+ ">");
        break;
    }
    if(SpreeBraintreeVzero.admin)
      $(formId).append("<input type='hidden' name='payment_method_nonce' value=" + data.nonce + ">");
    else
      $(formId).append("<input type='hidden' name='order[payments_attributes][][braintree_nonce]' value=" + data.nonce + ">");
    $(formId)[0].submit();
  }

  if (SpreeBraintreeVzero.threeDSecure && result.type == "CreditCard") {
    var client = new braintree.api.Client({
      clientToken: clientToken
    });

    client.verify3DS({
      amount: <%= @order.total %>,
      creditCard: result.nonce
    }, function (error, response) {
      if (!error) {
        submitWithAttributes(response);
      } else {
        $(errorMessagesContainer).prepend("<div class='alert alert-error'><%= I18n.t(:gateway_error, scope: 'braintree.error') %></div>")
      }
    });
  } else {
      submitWithAttributes(result);
  }
},

onReady: function (integration) {
  if(!SpreeBraintreeVzero.admin)
    SpreeBraintreeVzero.deviceData = integration.deviceData;
  <%= render partial: 'spree/checkout/payment/braintree_vzero/dropin_on_ready_callback', formats: [:js] %>
},

onError: function (error) {
  SpreeBraintreeVzero.enableSubmitButton();
  <%= render partial: 'spree/checkout/payment/braintree_vzero/dropin_on_error_callback', formats: [:js] %>
}

