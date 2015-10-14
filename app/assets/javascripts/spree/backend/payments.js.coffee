$(document).ready ->

  SpreePayments =

    init: ->
      @applyMaskOnDescriptorName()
      @toggleAdvancedPreferences()

    applyMaskOnDescriptorName: ->
      $('[id*="_preferred_descriptor_name"]').mask("***/*?*****************")

    toggleAdvancedPreferences: ->
      $('#advanced-preferences-heading').on 'click', ->
        $('#advanced-preferences').slideToggle()
        $('#advanced-preferences').toggleClass('collapsed')
        $('span.icon', $(this)).toggleClass('icon-chevron-down')


  SpreePayments.init()
  return
