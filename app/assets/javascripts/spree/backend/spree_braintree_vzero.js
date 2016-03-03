// Placeholder manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/backend/all.js'
//= require maskedinput/jquery.maskedinput.min
//= require spree/backend/payments

SpreeBraintreeVzero = {
  updateSaveAndContinueVisibility: function() {
    if (this.isButtonHidden()) {
      $(this).trigger('hideSaveAndContinue')
    } else {
      $(this).trigger('showSaveAndContinue')
    }
  },
  isButtonHidden: function () {
    if(this.paypal) return false;
    paymentMethod = this.checkedPaymentMethod();
    return (!$('#use_existing_card_yes:checked').length && SpreeBraintreeVzero.paymentMethodID && paymentMethod.val() == SpreeBraintreeVzero.paymentMethodID);
  },
  checkedPaymentMethod: function() {
    return $('form#new_payment input[type="radio"][name="payment[payment_method_id]"]:checked');
  },
  hideSaveAndContinue: function() {
    $(".base-btn").hide();
    $("[method_id='" + SpreeBraintreeVzero.paymentMethodID + "']").show();
    $(".new-braintree-payment-method").show();
    $(".show-new-payment").hide();
  },
  showSaveAndContinue: function() {
    $(".base-btn").show();
    $("[method_id='" + SpreeBraintreeVzero.paymentMethodID + "']").hide();
    $(".new-braintree-payment-method").hide();
    $(".brainree-submit").hide();
    $(".show-new-payment").show();
  },
  setSaveAndContinueVisibility: function() {
    if($('#saved_payment_methods_for_' + SpreeBraintreeVzero.paymentMethodID).val())
      SpreeBraintreeVzero.showSaveAndContinue();
    else
      SpreeBraintreeVzero.updateSaveAndContinueVisibility();
  },
  enableSubmitButton: function() {
    $('.braintree-submit:disabled').attr('disabled', false).removeClass('disabled').addClass('primary');
  },
  setPaypalButtonDispay: function() {
    submitButton = $('button[type="submit"]:not(.braintree-submit)');
    paymentMethod = this.checkedPaymentMethod();
    submitButton.attr('disabled', false);
    if(!SpreeBraintreeVzero.paymentMethodID || (paymentMethod.val() != SpreeBraintreeVzero.paymentMethodID))
      return;
    if(SpreeBraintreeVzero.paypal && SpreeBraintreeVzero.paypal_empty)
      submitButton.attr('disabled', true);
  }
}

$(document).ready(function() {
  SpreeBraintreeVzero.checkedPaymentMethod().trigger('click');
  paymentMethods = $('form#new_payment input[type="radio"]').click(function (e) {
    SpreeBraintreeVzero.setSaveAndContinueVisibility();
    SpreeBraintreeVzero.setPaypalButtonDispay();
  });
  $('.saved-payment-methods').change(function (e) {
    if($(this).val())
      SpreeBraintreeVzero.showSaveAndContinue();
    else {
      if(!SpreeBraintreeVzero.paypal)
        SpreeBraintreeVzero.hideSaveAndContinue();
    }
  });
  $('#show-new-payment').click(function (e) {
    e.preventDefault();
    $('#saved_payment_methods_for_' + SpreeBraintreeVzero.paymentMethodID).val('')
    SpreeBraintreeVzero.updateSaveAndContinueVisibility();
  });
  $('button[name="button"]:not(.braintree-submit)').click(function (e) {
    if($('form#new_payment').length) {
      e.preventDefault();
      token = $('#saved_payment_methods_for_' + SpreeBraintreeVzero.paymentMethodID).val()
      if(token)
        $('form#new_payment').append("<input type='hidden' name='payment_method_token]' value=" + token + ">");
      $('form#new_payment').submit();
    }
  });
  SpreeBraintreeVzero.setSaveAndContinueVisibility();
})
