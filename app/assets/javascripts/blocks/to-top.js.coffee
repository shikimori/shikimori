scroll_locked = false
to_top_visible = false

$to_top = null
scroll_binded = false

$(document).on 'page:load', ->
  return if is_mobile()

  $to_top = $(".b-to-top")

  $to_top.on 'click', ->
    $to_top.fadeOut()
    to_top_visible = false
    $('body,html').animate {scrollTop: 0}, 50

  unless scroll_binded
    scroll_binded = true

    $(window).on 'scroll:throttled', ->
      if $(window).scrollTop() != 0
        unless to_top_visible
          $to_top.fadeIn()
          to_top_visible = true
      else
        if to_top_visible
          $to_top.fadeOut()
          to_top_visible = false
