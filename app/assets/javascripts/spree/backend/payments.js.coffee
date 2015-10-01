$(document).ready ->

  SpreePayments =

    init: ->
      @applyMaskOnDescriptorName()

    applyMaskOnDescriptorName: ->
      $('#gateway_braintree_vzero_preferred_descriptor_name').mask("***/*?*****************")


  SpreePayments.init()
  return
