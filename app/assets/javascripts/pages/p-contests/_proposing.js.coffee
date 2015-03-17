@on 'page:load', 'contests_show', ->
  return unless $('.proposing').exists()

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

  $suggest = $('.proposing .item-suggest')
  suggest_placeholder = if $suggest.data('member_type') == 'anime'
    'Название аниме...'
  else
    'Имя персонажа...'

  $suggest
    .prop placeholder: suggest_placeholder
    .completable()
    .on 'autocomplete:success', (e, entry) ->
      $(@).val entry.name
      $(@).parents('form').find('#contest_suggestion_item_id').val entry.id
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
