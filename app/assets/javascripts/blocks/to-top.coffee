to_top_visible = null
$to_top = null

scroll_disabled = false
scroll_binded = false

$(document).on 'page:load', ->
  return if is_mobile()

  $to_top = $(".b-to-top")
  to_top_visible = null

  toggle()

  $to_top.on 'click', ->
    hide()
    scroll_disabled = true
    $('body,html').animate { scrollTop: 0 }, 50, -> scroll_disabled = false

  unless scroll_binded
    scroll_binded = true
    $(window).on 'scroll:throttled', toggle

toggle = ->
  return if scroll_disabled

  if $(window).scrollTop() > $('.l-top_menu').height()
    show()
  else
    hide()

show = ->
  if to_top_visible == null || to_top_visible == false
    $to_top.addClass('active')
    to_top_visible = true

hide = ->
  if to_top_visible == null || to_top_visible == true
    $to_top.removeClass('active')
    to_top_visible = false
