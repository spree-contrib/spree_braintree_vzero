//= require spree/frontend

SpreeBraintreeVzero = {
  updateSaveAndContinueVisibility: function() {
    if (this.isButtonHidden()) {
      $(this).trigger('hideSaveAndContinue')
    } else {
      $(this).trigger('showSaveAndContinue')
    }
  },
  isButtonHidden: function () {
    paymentMethod = this.checkedPaymentMethod();
    return (!$('#use_existing_card_yes:checked').length && SpreeBraintreeVzero.paymentMethodID && paymentMethod.val() == SpreeBraintreeVzero.paymentMethodID);
  },
  checkedPaymentMethod: function() {
    return $('div[data-hook="checkout_payment_step"] input[type="radio"][name="order[payments_attributes][][payment_method_id]"]:checked');
  },
  hideSaveAndContinue: function() {
    this.enableSubmitButton();
    if(!$('div[data-hook="checkout_payment_step"]').length) return
    $('.button').hide();
    $("[method_id='" + SpreeBraintreeVzero.paymentMethodID + "']").show();
    $(".new-braintree-payment-method").show();
    $(".show-new-payment").hide();
  },
  showSaveAndContinue: function() {
    this.enableSubmitButton();
    if(!$('div[data-hook="checkout_payment_step"]').length) return
    $("[method_id='" + SpreeBraintreeVzero.paymentMethodID + "']").hide();
    $('[name="commit"]:not(.braintree-submit)').show();
    $(".new-braintree-payment-method").hide();
    $(".show-new-payment").show();
  },
  setSaveAndContinueVisibility: function() {
    if($('#saved_payment_methods_for_' + SpreeBraintreeVzero.paymentMethodID).val())
      SpreeBraintreeVzero.showSaveAndContinue();
    else
      SpreeBraintreeVzero.updateSaveAndContinueVisibility();
  },
  enableSubmitButton: function() {
    $('.button:disabled').attr('disabled', false).removeClass('disabled').addClass('primary');
  },
  addDeviceData: function() {
    if(SpreeBraintreeVzero.deviceData)
      $(SpreeBraintreeVzero.checkoutFormId).append("<input type='hidden' name='device_data' value=" + SpreeBraintreeVzero.deviceData + ">");
  }
}

$(document).ready(function() {
  paymentMethods = $('div[data-hook="checkout_payment_step"] input[type="radio"]').click(function (e) {
    SpreeBraintreeVzero.setSaveAndContinueVisibility();
  });
  $('.saved-payment-methods').change(function (e) {
    if($(this).val())
      SpreeBraintreeVzero.showSaveAndContinue();
    else
      SpreeBraintreeVzero.hideSaveAndContinue();
  });
  $('#show-new-payment').click(function (e) {
    e.preventDefault();
    $('#saved_payment_methods_for_' + SpreeBraintreeVzero.paymentMethodID).val('')
    SpreeBraintreeVzero.updateSaveAndContinueVisibility();
  });
  $('#paypal-submit').click(function (e) {
    e.preventDefault();
  });
  $('[name="commit"]:not(.braintree-submit)').click(function (e) {
    if($('#checkout-step-payment').length) {
      e.preventDefault();
      token = $('#saved_payment_methods_for_' + SpreeBraintreeVzero.paymentMethodID).val()
      if(token)
        $(SpreeBraintreeVzero.checkoutFormId).append("<input type='hidden' name='order[payments_attributes][][braintree_token]' value=" + token + ">");
      $('#checkout_form_payment').submit();
    }
  });
  $('.braintree-submit, [name="commit"]').click(function(e) {
    SpreeBraintreeVzero.addDeviceData();
  });
  SpreeBraintreeVzero.setSaveAndContinueVisibility();
})
