@on 'page:load', 'recommendations_index', ->
  # если страница ещё не готова, перегрузимся через 5 секунд
  if $('p.pending').exists()
    Turbolinks.visit.delay 5000, location.href, true

  $('body').on 'mouseover', '.b-catalog-entry', ->
    $node = $(@)
    return if $node.hasClass 'entry-ignored'

    if $node.data 'ignore_augmented'
      $node.data('ignore_button').show()
    else
      $button = $('<span class="image-delete mark-ignored" title="Больше не рекомендовать эту франшизу"></span>').appendTo($node.children('a'))
      $node.data
        ignore_augmented: true
        ignore_button: $button

  $('body').on 'mouseout', '.b-catalog-entry', ->
    $button = $(@).data('ignore_button')
    $button.hide() if $button

  $('body').on 'click', '.entry-ignored', (e) ->
    false unless in_new_tab(e)

  $('body').on 'click', '.b-catalog-entry .mark-ignored', ->
    $node = $(@).closest '.b-catalog-entry'
    $link = $node.find('a')

    if $link.attr('href').match /(anime|manga)s\/(\d+)/
      target_type = RegExp.$1
      target_id = RegExp.$2

      $.post '/recommendation_ignores', target_type: target_type, target_id: target_id, (data) ->
        selector = _(data).map((v) -> ".entry-#{v}").join(',')
        $(selector).addClass 'entry-ignored'

      $node.addClass 'entry-ignored'
      $(@).hide()
      AjaxCacher.reset()
