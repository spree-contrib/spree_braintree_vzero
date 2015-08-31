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
    $("[data-hook=buttons]").hide();
  },
  showSaveAndContinue: function() {
    $("[data-hook=buttons]").show();
  }
}

$(document).ready(function() {
  SpreeBraintreeVzero.updateSaveAndContinueVisibility();
  paymentMethods = $('div[data-hook="checkout_payment_step"] input[type="radio"]').click(function (e) {
    SpreeBraintreeVzero.updateSaveAndContinueVisibility();
  });
})
