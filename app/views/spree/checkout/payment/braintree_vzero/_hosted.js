id: checkoutFormId,
hostedFields: {
  styles: {
    <%= render partial: 'spree/checkout/payment/braintree_vzero/hosted_fields_styles', formats: [:js] %>
  },
  number: {
    selector: "<%= payment_method.preferred_number_selector %>",
    placeholder: "<%= payment_method.preferred_number_placeholder %>"
  },
  cvv: {
    selector: "<%= payment_method.preferred_cvv_selector %>",
    placeholder: "<%= payment_method.preferred_cvv_placeholder %>"
  },
  expirationDate: {
    selector: "<%= payment_method.preferred_expiration_date_selector %>",
    placeholder: "<%= payment_method.preferred_expiration_date_placeholder %>"
  },

  onFieldEvent: function (event) {
    <%= render partial: 'spree/checkout/payment/braintree_vzero/hosted_fields_on_field_event_callback', formats: [:js] %>
  }
},

onPaymentMethodReceived: function (result) {
  function submitWithAttributes() {
    switch (result.type) {
      case "CreditCard":
        $(checkoutFormId).append("<input type='hidden' name='braintree_last_two' value=" + result.details.lastTwo + ">");
        $(checkoutFormId).append("<input type='hidden' name='braintree_card_type' value=" + result.details.cardType + ">");
        break;
      case "PayPalAccount":
        $(checkoutFormId).append("<input type='hidden' name='paypal_email' value=" + (result.details.email)+ ">");
        break;
    }
    $(checkoutFormId).append("<input type='hidden' name='order[payments_attributes][][braintree_nonce]' value=" + result.nonce + ">");
    $(checkoutFormId).submit();
  }

  if (SpreeBraintreeVzero.threeDSecure && result.type == "CreditCard") {
    var client = new braintree.api.Client({
      clientToken: clientToken
    });

    client.verify3DS({
      amount: <%= current_order.total %>,
      creditCard: result.nonce
    }, function (error, response) {
      if (!error) {
        submitWithAttributes();
      } else {
        $(errorMessagesContainer).prepend("<div class='alert alert-error'><%= I18n.t(:gateway_error, scope: 'braintree.error') %>></div>")
      }
    });
  } else {
      submitWithAttributes();
  }
}

