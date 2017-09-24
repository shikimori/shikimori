to_top_visible = null
$to_top = null

scroll_binded = false

$(document).on 'page:load', ->
  return if is_mobile()

  $to_top = $(".b-to-top")
  to_top_visible = null

  toggle()

  $to_top.on 'click', ->
    hide()
    $('body,html').animate {scrollTop: 0}, 50

  unless scroll_binded
    scroll_binded = true
    $(window).on 'scroll:throttled', toggle

toggle = ->
  if $(window).scrollTop() != 0
    show()
  else
    hide()

show = ->
  if to_top_visible == false
    $to_top.addClass('active')
    to_top_visible = true

hide = ->
  if to_top_visible == true
    $to_top.removeClass('active')
    to_top_visible = false
