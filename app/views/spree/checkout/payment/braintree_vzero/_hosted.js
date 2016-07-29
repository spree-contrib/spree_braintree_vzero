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

onError: function (error) {
  SpreeBraintreeVzero.enableSubmitButton();
},

onPaymentMethodReceived: function (result) {
  function submitWithAttributes(response = result) {
    switch (response.type) {
      case "CreditCard":
        $(checkoutFormId).append("<input type='hidden' name='braintree_last_two' value=" + response.details.lastTwo + ">");
        $(checkoutFormId).append("<input type='hidden' name='braintree_card_type' value=" + response.details.cardType + ">");
        break;
      case "PayPalAccount":
        $(checkoutFormId).append("<input type='hidden' name='paypal_email' value=" + (response.details.email)+ ">");
        break;
    }
    $(checkoutFormId).append("<input type='hidden' name='order[payments_attributes][][braintree_nonce]' value=" + response.nonce + ">");
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
        submitWithAttributes(response);
      } else {
        $(errorMessagesContainer).prepend("<div class='alert alert-error'><%= I18n.t(:gateway_error, scope: 'braintree.error') %>></div>")
      }
    });
  } else {
    submitWithAttributes();
  }
}

