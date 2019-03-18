$(document).on 'turbolinks:load', ->
  # переключение языка описания
  $('.b-lang_trigger').on 'click', ->
    $english = $('.english')
    if $english.is(':visible')
      $english.hide()
      $('.russian').show()
      $('.changes').show()
      $(@).children().html 'eng'

    else
      $english.show()
      $('.russian').hide()
      $('.changes').hide()
      $(@).children().html 'рус'
