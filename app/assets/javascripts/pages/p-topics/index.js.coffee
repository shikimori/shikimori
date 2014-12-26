@on 'page:load', 'topics_index', ->
  $('.show-more').on 'click', ->
    $(@).hide().next().show()
