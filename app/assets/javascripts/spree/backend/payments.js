$(function() {
  var SpreePayments = {
    init: function() {
      this.applyMaskOnDescriptorName()
      this.toggleAdvancedPreferences()
    },
    applyMaskOnDescriptorName: function() {
      $('[id*="_preferred_descriptor_name"]').mask('***/*?*****************')
    },
    toggleAdvancedPreferences: function() {
      $('#advanced-preferences-heading').on('click', function() {
        $('#advanced-preferences').slideToggle()
        $('#advanced-preferences').toggleClass('collapsed')
        $('span.icon', $(this)).toggleClass('icon-chevron-down')
      })
    }
  }
  SpreePayments.init()
})
