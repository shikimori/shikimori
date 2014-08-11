resize_player = ($page) ->
  $frame = $('iframe', $page)
  $frame.height($frame.width() * 9 / 16) if $frame

  $object = $('object', $page)
  if $object
    width = $object.parent().width()
    $object.width(width).height(width * 9 / 16)
    $('embed', $object).width(width).height(width * 9 / 16)

jQuery ->
  $page = $('.p-anime_video-show')

  $('.kinds li a', $page).on 'click', ->
    $('.video iframe', $page).attr 'src', $(@).data('url')

  $('a', '.report li').on 'ajax:success', ->
    alert 'Ваше обращение принято. Спасибо!'

  resize_player $page
  $(window).resize -> resize_player($page)

  $("a.dropdown-toggle, .dropdown-menu a").on "touchstart", (e) ->
    e.stopPropagation()

  $('li.rate a', $page).on 'ajax:success', ->
    $('li.rate a', $page).addClass 'hide'
    $('li.ok', $page).removeClass 'hide'

  $('button.upload', $page).on 'click', ->
    window.location = $(@).data('href')
