$ ->
  $('.collapsed').on 'click', ->
    $iframe = $('iframe', $(@).parent())
    $iframe.attr 'src', $iframe.data('url')
