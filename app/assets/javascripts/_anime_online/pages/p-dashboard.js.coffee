$(document.body).on 'click', 'p.show-more', ->
  $(@).hide().next().show()
