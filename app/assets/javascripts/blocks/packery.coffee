$ ->
  $(window).on 'resize:debounced', ->
    $('.packery').each ->
      packery = $(@).data('packery')

      packery.layout()
      delay(1250).then => packery.layout()
