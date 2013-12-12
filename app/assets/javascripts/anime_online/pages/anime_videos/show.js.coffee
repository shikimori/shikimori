jQuery ->
  $page = $('.p-anime_video-show')

  $('.kinds li a', $page).on 'click', ->
    $('.video iframe', $page).attr 'src', $(@).data('url')

  $('a', '.complaint li').on 'click', ->
    $.ajax
      url: $(@).data('url')
      type: 'POST'
      success: ->
        alert 'Ваше обращение принято. Спасибо!'

  frame = $('iframe', $page)
  frame.height(frame.width() * 9 / 16)

  $("a.dropdown-toggle, .dropdown-menu a").on "touchstart", (e) ->
    e.stopPropagation()
