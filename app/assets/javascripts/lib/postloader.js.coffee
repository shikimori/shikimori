# динамическая подгрузка контента по мере прокрутки страницы
$(".postloader").appear()
$(".postloader").live 'click appear', ->
  $postloader = $(@)
  return if $postloader.data('locked')
  #new_postloader = $postloader.hasClass('new')

  # для нового лоадера никаких манипуляций делать не нужно
  #if new_postloader
  $postloader.html "<div class=\"ajax-loading vk-like\" title=\"Загрузка...\" />"

  #else
    #$postloader.hide()
    #$loader = $postloader.next()
    #if $loader.hasClass('postloader-progress')
      #$loader
        #.css(visibility: 'visible')
        #.show()
    #else
      #$loader = $("<div class=\"ajax-loading vk-like\" title=\"Загрузка...\" />").insertAfter($postloader)

  url = $postloader.data('remote')
  if !url
    $postloader.trigger 'postloader:trigger'

  else
    $postloader.data "locked", true
    $.getJSON url, (data) ->
      $data = $(data.content)

      # передаём в колбек данные, а затем трём элемент
      $postloader.trigger 'postloader:success', [$data]

      # после колбеказабираем данные из filtered-data
      $data = $postloader.data('filtered-data')
      #if new_postloader
      $postloader.replaceWith $data

      #else
        #$postloader.remove()
        #$loader.replaceWith $data

      process_current_dom()
      $postloader.data locked: false
      $('.ajax').trigger 'postloader:success'

# удаляем уже имеющиеся подгруженные элементы
$('.postloader').live 'postloader:success', (e, $data) ->
  filter = $(@).data('filter') || 'comment'
  regex = new RegExp("#{filter}-\\d+")
  $present_entries = $(".#{filter}-block")

  exclude_selector = _.compact(_.map($present_entries, (v, k) ->
    ".#{match[0]}" if match = v.className.match(regex)
  )).join(', ')

  $(@).data 'filtered-data', $data.not(exclude_selector)
