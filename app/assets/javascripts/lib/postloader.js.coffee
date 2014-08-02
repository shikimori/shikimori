$ ->
  $('.b-postloader').appear()

# динамическая подгрузка контента по мере прокрутки страницы
$(document).on 'click appear', '.b-postloader', ->
  $postloader = $(@)
  return if $postloader.data('locked')

  $postloader.html "<div class=\"ajax-loading vk-like\" title=\"Загрузка...\" />"
  url = $postloader.data('remote')

  $postloader.data locked: true

  $.getJSON url, (data) ->
    $data = $('<div>').append data.content

    filter_present_entries $postloader, $data, $(@).data('filter')
    $postloader.trigger 'postloader:success', [$data, data]
    $postloader.replaceWith $data.children()

    process_current_dom()
    $postloader.data locked: false

# удаляем уже имеющиеся подгруженные элементы
filter_present_entries = ($postloader, $new_entries, filter) ->
  regex = new RegExp("#{filter}-\\d+")
  $present_entries = $(".#{filter}-block")

  exclude_selector = _.compact(_.map($present_entries, (v, k) ->
    ".#{match[0]}" if match = v.className.match(regex)
  )).join(', ')

  $new_entries.children().filter(exclude_selector).remove()
