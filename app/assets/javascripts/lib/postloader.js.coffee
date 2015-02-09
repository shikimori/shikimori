$ ->
  $('.b-postloader').appear()

# динамическая подгрузка контента по мере прокрутки страницы
$(document).on 'click appear', '.b-postloader', (e) ->
  $postloader = $(@)
  return if $postloader.data('locked') || (e.type == 'appear' && $postloader.data('ignore-appear'))

  $postloader.html "<div class=\"ajax-loading vk-like\" title=\"Загрузка...\" />"
  url = $postloader.data('remote')
  filter = $postloader.data('filter')

  $postloader.data locked: true

  $.getJSON url, (data) ->
    $data = $('<div>').append("#{data.content}#{data.postloader}")

    filter_present_entries $data, filter if filter
    $postloader.trigger 'postloader:success', [$data, data]
    $postloader.replaceWith $data.children()

    process_current_dom()
    $postloader.data locked: false

# удаляем уже имеющиеся подгруженные элементы
filter_present_entries = ($new_entries, filter) ->
  present_ids = $(".#{filter}").toArray().map (v) -> v.id

  exclude_selector = present_ids.map (id) ->
      ".#{filter}##{id}"
    .join(',')

  $new_entries.children().filter(exclude_selector).remove()
