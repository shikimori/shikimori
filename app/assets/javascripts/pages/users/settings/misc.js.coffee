$('.slide > div.settings').on 'ajax:success cache:success', (e, data) ->
  if !$('.recommendations-cleanup').length
    return

  # восстановление залокированных рекомендаций
  # выбор варианта
  $('.recommendations-cleanup .controls .link').on 'click', ->
    type = $(@).data 'type'
    $(@)
      .closest('.controls')
      .hide()

    $(@)
      .closest('.recommendations-cleanup')
      .find(".form.#{type}")
      .show()

  # отмена
  $('.recommendations-cleanup .cancel').on 'click', ->
    $('.recommendations-cleanup .controls').show()
    $('.recommendations-cleanup .form').hide()
