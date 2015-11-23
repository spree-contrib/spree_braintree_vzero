$(document).ready ->

  SpreePayments =

    init: ->
      @applyMaskOnDescriptorName()
      @toggleAdvancedPreferences()

    applyMaskOnDescriptorName: ->
      $('[id*="_preferred_descriptor_name"]').mask("***/*?*****************")

  SpreePayments.init()
  return
