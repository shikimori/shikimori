list_cache = []
filter_timer = null
$ ->
  DEFAULT_LIST_SORT = $('.default-sort').data('value')
  $('.anime-filter .genres .collapse,.manga-filter .genres .collapse').trigger 'click', true
  get_anime_params()
  get_manga_params()
  return


# активация списка
$('.animelist, .mangalist').live 'ajax:success cache:success', (e, data) ->
  # тормозит на анимации
  $('.slide > .selected').addClass 'no-animation'
  $('.animanga-filter').hide()

  if @className.match /anime|manga/
    type = (if @className.match(/anime/) then 'anime' else 'manga')
    $(".#{type}-filter").show()

    parse_function = if type is 'anime' then get_anime_params else get_manga_params
    unless @className.match(/list/)
      mylist = $(@).parent().index() - (if type == 'anime' then 9 else 9 + 6)
      parse_function().parse "/mylist/#{mylist}/order-by/my"
    else
      if @className.match(/list/)
        parse_function().parse location.href.replace(/http:\/\/.*?\//, "/")


  # клики на фильтры по списку в начале страницы
  $(document.body).on 'click', '.ani-manga-list .link', ->
    $(@).toggleClass 'selected'
    id = $(@).data 'id'
    $(".animanga-filter:visible .mylist li.mylist-#{id}").trigger 'click'



# сортировка по клику на колонку
$('.order-control').live 'click', (e) ->
  type = $(@).data('order')
  $(".animanga-filter:visible .orders.anime-params li.order-by-#{type}").trigger 'click'

# при выборе сортировке будем ставить её в дефолтные
$('.anime-params-controls .orders li, .manga-params-controls .orders li').live 'click', ->
  DEFAULT_LIST_SORT = $(this).attr('class').match(/order-by-([\w-]+)/)[1] if IS_LOGGED_IN

# парсинг параметров из урла для анимелиста
get_anime_params = ->
  return arguments.callee.params if 'params' of arguments.callee
  $link = $('.slider-control-animelist a')
  return unless $link.length

  arguments.callee.params = new AnimeCatalogFilters($link.attr("href").replace(/^http:\/\/.*?\//, "/"), location.href, (data) ->
    return unless data.match(/anime/)
    $('.slide > .animelist').append "<div class=\"clear-marker\"></div>"
    $('.slider-control-animelist a').attr(href: data).trigger 'click'
  , $('.anime-filter'))

  arguments.callee.params

# парсинг параметров из урла для мангалиста
get_manga_params = ->
  return arguments.callee.params if 'params' of arguments.callee
  $link = $(".slider-control-mangalist a")
  return unless $link.length

  arguments.callee.params = new AnimeCatalogFilters($link.attr("href").replace(/^http:\/\/.*?\//, "/"), location.href, (data) ->
    return unless data.match(/manga/)
    $('.slide > .mangalist').append "<div class=\"clear-marker\"></div>"
    $('.slider-control-mangalist a').attr(href: data).trigger 'click'
  , $('.manga-filter'))

  arguments.callee.params
