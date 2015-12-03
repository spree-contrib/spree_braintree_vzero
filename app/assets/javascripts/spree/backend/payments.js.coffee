$(document).ready ->

  SpreePayments =

    init: ->
      @applyMaskOnDescriptorName()

    applyMaskOnDescriptorName: ->
      $('[id*="_preferred_descriptor_name"]').mask("***/*?*****************")

  SpreePayments.init()
  return
