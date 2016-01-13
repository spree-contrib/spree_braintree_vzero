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
    $("[data-hook=buttons]").hide();
    $(".new-braintree-payment-method").show();
  },
  showSaveAndContinue: function() {
    $("[data-hook=buttons]").show();
    $(".new-braintree-payment-method").hide();
  },
  setSaveAndContinueVisibility: function() {
    if($('#saved_payment_methods_for_' + SpreeBraintreeVzero.paymentMethodID).val())
      SpreeBraintreeVzero.showSaveAndContinue();
    else
      SpreeBraintreeVzero.updateSaveAndContinueVisibility();
  },
  enableSubmitButton: function() {
    $('.braintree-submit:disabled').attr('disabled', false).removeClass('disabled').addClass('primary');
  }
}

$(document).ready(function() {
  paymentMethods = $('form#new_payment input[type="radio"]').click(function (e) {
    SpreeBraintreeVzero.setSaveAndContinueVisibility();
  });
  $('.saved-payment-methods').change(function (e) {
    if($(this).val())
      SpreeBraintreeVzero.showSaveAndContinue();
    else {
      if(!this.paypal)
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
