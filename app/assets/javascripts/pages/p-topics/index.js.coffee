@on 'page:load', 'topics_index', ->
  $('.b-show_more').on 'click', ->
    $(@).hide().next().show()
  $('.b-show_more-more .hide-more').on 'click', ->
    $(@).parent().hide().prev().show()
