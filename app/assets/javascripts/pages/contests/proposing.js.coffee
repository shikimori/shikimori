$voters = (node) ->
  $(node)
    .parents('.suggestion')
    .find('.voters-container')

$hide = (node) ->
  $(node)
    .parents('.suggestion')
    .find('.hide')

$show = (node) ->
  $(node)
    .parents('.suggestion')
    .find('.show')

$ ->
  suggest_placeholder = if $('.proposing .item-suggest').data('member_type') == 'anime'
    'Название аниме...'
  else
    'Имя персонажа...'

  $('.proposing .item-suggest').make_completable suggest_placeholder
  $('.proposing .item-suggest').on 'autocomplete:success', (e, id, text, label) ->
    $(@).val text
    $(@).parents('form').find('#contest_suggestion_item_id').val id
    $(@).parents('form').submit()

  $('.proposing form').on 'submit', ->
    if _.isEmpty $(@).find('#contest_suggestion_item_id').val()
      false

  $('.proposing .suggestion .show').on 'click', ->
    $voters(@).show()
    $hide(@).show()
    $show(@).hide()

  $('.proposing .suggestion .hide').on 'click', ->
    $voters(@).hide()
    $hide(@).hide()
    $show(@).show()

  $('.proposing .suggestion .show.ajaxable').on 'click', (e, html) ->
    return if !$(@).hasClass('ajaxable')
    $(@).removeClass 'ajaxable'
    $.get($(@).data 'href').success (data, status, xhr) =>
      $(@).trigger 'ajax:success', data

  $('.proposing .suggestion .show').on 'ajax:success', (e, html) ->
    $voters(@).html(html)
