# динамическая подгрузка контента по мере прокрутки страницы
$(".b-postloader").appear()
$(".b-postloader").live 'click appear', ->
  $postloader = $(@)
  return if $postloader.data('locked')

  $postloader.html "<div class=\"ajax-loading vk-like\" title=\"Загрузка...\" />"
  url = $postloader.data('remote')

  $postloader.data locked: true

  $.getJSON url, (data) ->
    $data = $('<div>').append data.content

    # передаём в колбек данные, а затем трём элемент
    $postloader.trigger 'postloader:success', [$data, data]
    $postloader.replaceWith $data.children()

    process_current_dom()
    $postloader.data locked: false

# удаляем уже имеющиеся подгруженные элементы
$('.b-postloader').live 'postloader:success', (e, $data) ->
  filter = $(@).data('filter') || 'comment'
  regex = new RegExp("#{filter}-\\d+")
  $present_entries = $(".#{filter}-block")

  exclude_selector = _.compact(_.map($present_entries, (v, k) ->
    ".#{match[0]}" if match = v.className.match(regex)
  )).join(', ')

  $data.children().filter(exclude_selector).remove()
