$ ->
  return unless document.body.id.startsWith 'dashboard_'

  $('.show-more').on 'click', ->
    $(@).hide().next().show()
