list_cache = []
$ ->
  DEFAULT_LIST_SORT = $('.default-sort').data('value')
  $('.anime-filter .genres .collapse,.manga-filter .genres .collapse').trigger 'click', true
  get_anime_params()
  get_manga_params()
  return

# активация списка
$('.animelist, .mangalist').live "ajax:success cache:success", (e, data) ->
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

  apply_list_handlers()
  update_list_cache()

# при выборе сортировке будем ставить её в дефолтные
$('.anime-params-controls .orders li, .manga-params-controls .orders li').live 'click', ->
  DEFAULT_LIST_SORT = $(this).attr('class').match(/order-by-([\w-]+)/)[1] if IS_LOGGED_IN

# клики на фильтры по списку в начале страницы
$(document.body).on 'click', '.ani-manga-list .link', ->
  $(@).toggleClass 'selected'
  id = $(@).data 'id'
  $(".animanga-filter:visible .mylist li.mylist-#{id}").trigger 'click'

# фокус по инпуту фильтра по тайтлу
$(document.body).on 'focus', '.ani-manga-list .filter input', ->
  update_list_cache() unless list_cache.length

# разворачивание свёрнутых блоков при фокусе на инпут
$(document.body).on 'focus', '.ani-manga-list .filter input', ->
  $('.collapsed', $(@).closest('.slide')).each ->
    $(@).trigger 'click' if @style.display == 'block'

filter_timer = null
# пишут в инпуте фильтра по тайтлу
$(document.body).on 'keyup', '.ani-manga-list .filter input', (e) ->
  return if e.keyCode is 91 or e.keyCode is 18 or e.keyCode is 16 or e.keyCode is 17

  if filter_timer
    clearInterval filter_timer
    filter_timer = null

  filter_timer = setInterval(filter, 350)

# удаление из списка
$('.anime-remove').live 'ajax:success', ->
  $(@).closest('tr').remove()
  false

# обработчик для плюсика у числа эпизодов/глав
$('.selected .ani-manga-list .hoverable .item-add').live 'click', (e) ->
  $input = $(@).prev()
  $input.val(parseInt($input.val(), 10) + 1).trigger 'blur'
  e.stopPropagation()
  false

# обработчики для инпутов листа
$('.selected .ani-manga-list .hoverable input').live('blur', ->
  $this = $(@)
  $this.parent().parent().trigger 'mouseleave'
  @value = 0  if @value < 0
  return if (parseInt(@value, 10) or 0) is (parseInt($this.data('counter'), 10) or 0)

  $value = $this.parent().parent().find(".current-value")
  prior_value = $value.html()
  $this.data 'counter', @value
  $value.html (if $this.data('counter') == '0' then '&ndash;' else $this.data('counter'))
  $.cursorMessage()

  $.post($this.data('action'), "_method=patch&rate[#{$this.data 'field'}]=#{$this.attr 'value'}").success( ->
    $.hideCursorMessage()
  ).error ->
    $.hideCursorMessage()
    $value.html prior_value
    $.flash alert: 'Произошла ошибка'

).live('mousewheel', (e) ->
  return true unless $(@).is(':focus')

  if e.originalEvent.wheelDelta && e.originalEvent.wheelDelta > 0
    @value = Math.min (parseInt(@value, 10) + 1 or 0), parseInt($(@).data('max'), 10)

  else if e.originalEvent.wheelDelta
    @value = Math.max (parseInt(@value, 10) - 1 or 0), parseInt($(@).data('min'), 10)

  false
).live('keydown', (e) ->
  if e.keyCode is 38
    @value = Math.min (parseInt(@value, 10) + 1 or 0), parseInt($(@).data('max'), 10)

  else if e.keyCode is 40
    @value = Math.max (parseInt(@value, 10) - 1 or 0), parseInt($(@).data('min'), 10)

  else if e.keyCode is 27
    @value = $(@).data('counter')
    $(@).trigger 'blur'

).live 'keypress', (e) ->
  if e.keyCode is 13
    $(@).trigger 'blur'
    e.stopPropagation()
    false


# сортировка по клику на колонку
$(".order-control").live "click", (e) ->
  type = $(this).data("order")
  $(".animanga-filter:visible .orders.anime-params li.order-by-" + type).trigger "click"
  return


# скрытие слайдов с аниме
$(".slide > div").live "ajax:clear", (e, page) ->
  $(".animanga-filter").hide()  unless page.match(/anime|manga/)
  return


# активация изменения статуса
$(".selected .anime-status").live "click", ->
  $this = $(this)
  $selector = $this.parents("td").children(".anime-status-selector")

  # если нет селектора - создаём
  unless $selector.length
    $selector = $this.parents(".ani-manga-list").children(".anime-status-selector").clone().data("field", $this.data("field")).data("action", $this.parents("tr").data("action"))
    $this.parents("td").prepend $selector
  $selector.show()
  $this.hide()
  $(window).one "click", (e) ->
    return  if e.target is $selector[0]
    $selector.hide()
    e.stopPropagation()
    false

  false

$(".selected .anime-status-selector").live "change", (e) ->
  $this = $(this)
  $.cursorMessage()

  $.post($this.data("action"), "_method=patch&rate[" + $this.data("field") + "]=" + $this.attr("value")).success(->
    $.hideCursorMessage()
    $this.hide()
  ).error ->
    $.hideCursorMessage()
    $this.hide()
    $.flash alert: "Произошла ошибка"

  false

$(".selected .anime-status-selector").live "click", (e) ->
  e.stopPropagation()
  false

# открытие блока с редактирование записи по клику на неё
$("tr.editable").live "click", (e) ->

# подгрузка списка аниме
$(".selected .ani-manga-list .postloader").live "postloader:success", (e, $data) ->
  $header = $data.filter("header:first")
  # при подгрузке могут быть 2 случая:
  # 1. подгружается совершенно новый блок, и тогда $header будет пустым
  # 2. погружается дальнейший контент уже существующего блока, и тогда...

  # заголовок скрываем, ставим ему класс collapse-merged и collapse-ignored(чтобы раскрытие collapsed работало корректно),
  # а так же таблице ставим класс merged и скрываем её заголовок
  $header.addClass("collapse-merged").addClass("collapse-ignored").hide().next().addClass("collapse-merged").find("tr:first,tr.border").hide()  if $(".ani-manga-list header." + $header.attr("class")).length > 0
  _.delay (->
    apply_list_handlers()
    update_list_cache()
    $input = $(".selected .ani-manga-list .filter input")
    $input.trigger "keyup"  unless _.isEmpty($input.val())
  ), 250

# парсинг параметров из урла для анимелиста
get_anime_params = ->
  return arguments.callee.params if 'params' of arguments.callee
  $link = $('.slider-control-animelist a')
  return unless $link.length

  arguments.callee.params = new AniMangaParamsParser($link.attr("href").replace(/^http:\/\/.*?\//, "/"), location.href, (data) ->
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

  arguments.callee.params = new AniMangaParamsParser($link.attr("href").replace(/^http:\/\/.*?\//, "/"), location.href, (data) ->
    return unless data.match(/manga/)
    $('.slide > .mangalist').append "<div class=\"clear-marker\"></div>"
    $('.slider-control-mangalist a').attr(href: data).trigger 'click'
  , $('.manga-filter'))

  arguments.callee.params

# фильтрация списка пользователя
filter = ->
  clearInterval filter_timer
  filter_timer = null
  $slide = $('.slide > .selected')

  # разворачивание свёрнутых элементов
  filter = $('.filter input', $slide).val().toLowerCase()
  $entries = $('tr.selectable', $slide)
  _(list_cache).each (block) ->
    visible = false
    i = 0

    while i < block.rows.length
      entry = block.rows[i]
      if entry.title.indexOf(filter) >= 0
        visible = true
        unless entry.display is ""
          entry.display = ""
          entry.node.style.display = ""
      else
        unless entry.display is "none"
          entry.display = "none"
          entry.node.style.display = "none"
      i++
    block.$nodes.toggle visible  if block.toggable
    block.$only_show.show()  if block.$only_show and visible
    return

  $.force_appear()
  return

# кеширование всех строчек списка для производительности
update_list_cache = ->
  $slide = $(".slide > .selected")
  list_cache = $("table", $slide).map(->
    $table = $(this)
    rows = $table.find("tr.selectable").map(->
      node: this
      title: String($(this).data("title"))
      display: @style.display
    ).toArray()
    $nodes = $table.add($table.prev(":not(.collapse-merged)"))

    # если текущая таблица подгружена пагинацией, тоесть она без заголовка, то...
    if $nodes.length is 1
      klass = $table.prev().attr("class").match(/status-\d/)[0]
      $only_show = $("." + klass + ":not(.collapse-merged)", $slide)
      $only_show = $only_show.add($only_show.next())
    $nodes: $nodes
    $only_show: $only_show
    rows: rows
    toggable: not $table.next(".postloader").length
  )
  return

# обработчики для списка
apply_list_handlers = ->
  # изменения статуса
  $(".selected .ani-manga-list tr.unprocessed").hover(->
    $selector = $(".anime-status", @parentNode)
    return  if not $selector.length or $selector.is(":visible")
    $(".anime-status", this).show()
    $(".anime-remove", this).show().prev().hide()
    return
  , ->
    $(".anime-status", this).hide()
    $(".anime-remove", this).hide().prev().show()
    return
  ).removeClass("unprocessed").find(".tooltipped").tooltip $.extend($.extend({}, tooltip_options),
    offset: [
      -95
      10
    ]
    position: "bottom right"
    opacity: 1
    onBeforeShow: null
    onBeforeHide: null
  )

  # изменения оценки/числа просмотренных эпизодов
  $(".selected .ani-manga-list .hoverable").unbind().hover(->
    $current_value = $(".current-value", this)
    $new_value = $(".new-value", this)

    # если нет элемента, то создаём его
    if $new_value.length is 0
      val = parseInt($current_value.children().html(), 10)
      val = 0  if not val and val isnt 0
      new_value_html = (if $current_value.data("field") isnt "score" then "<span class=\"new-value\"><input type=\"text\" class=\"input\"/><span class=\"item-add\"></span></span>" else "<span class=\"new-value\"><input type=\"text\" class=\"input\"/></span>")
      $new_value = $(new_value_html).children("input").val(val).data("counter", val).data("max", 10).data("min", 0).data("field", $current_value.data("field")).data("action", $current_value.parents("tr").data("action")).parent().insertAfter($current_value)
    $new_value.show()
    $current_value.hide()
    $(".misc-value", this).hide()
  , ->
    return if $(".new-value input", this).is(":focus")
    $(".new-value", this).hide()
    $(".current-value", this).show()
    $(".misc-value", this).show()
  ).click (e) ->
    # клик на плюсик обрабатываем по дефолтному
    return if e.target && e.target.className == 'item-add'
    $this = $(@)
    $this.trigger 'mouseenter'
    $('input', $this).trigger('focus').select()
    e.stopPropagation()
    false
