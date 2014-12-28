scroll_locked = false
to_top_visible = false

$to_top = null
scroll_binded = false

process = ->
  scroll_locked = false
  if $(window).scrollTop() isnt 0
    unless to_top_visible
      $to_top.fadeIn()
      to_top_visible = true
  else
    if to_top_visible
      $to_top.fadeOut()
      to_top_visible = false

$(document).on 'page:load', ->
  return if is_mobile()

  $to_top = $(".b-to-top")

  $to_top.on 'click', ->
    $to_top.fadeOut()
    $('body,html').animate
      scrollTop: 0
    , 50

  unless scroll_binded
    scroll_binded = true
    $(window).on 'scroll', ->
      unless scroll_locked
        scroll_locked = true
        process.delay(500)
