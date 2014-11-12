# автодополнение
$(document).on 'page:load', ->
  $main_search = $('.main-search')
  $search = $('.main-search input')
  $popup = $('.main-search .popup')

  return unless $('.main-search').exists()

  # из урла достаём текущий тип поиска
  type = location.pathname.replace(/^\//, "").replace(/\/.*/, "")
  type = $('.main-search .type').first().data('type') unless searcheables[type]

  # из урла достаём текущее значение поиска
  #var value = decodeURIComponent(location.pathname.replace(searcheables[type].regexp, '$1'));
  #if (value != location.pathname && !value.match(/^\d+-\w+/)) {
  #$search.val(value);
  #}

  # во всплывающей выборке типов устанавливаем текущий тип
  $(".type[data-type=#{type}], .type[data-type=#{type}]", $popup).addClass 'active'

  # автокомплит
  $search
    .data
      type: type
      autocomplete: searcheables[type].autocomplete
    .attr(placeholder: searcheables[type].title)
    .completable null, (e, id, text) ->
      @value = text if text
      return if @value is "" and not id
      type = $search.data("type")
      if id
        if type is "users"
          document.location.href = "/" + search_escape(text)
        else
          document.location.href = searcheables[type].id.replace("[id]", id)
      else
        document.location.href = searcheables[type].phrase.replace("[phrase]", search_escape($search.val()))
    , $(".main-search .suggest-placeholder")

  $search.on "parse", ->
    $popup.addClass "disabled"
    _.delay ->
      $(".ac_results:visible").addClass "menu-suggest"

  # переключение типа поиска
  $(".main-search .type").on 'click', ->
    $this = $(this)
    return if $this.hasClass("active")
    $this.addClass("active").siblings().removeClass "active"
    type = $this.data("type")
    $search.data("type", type).attr("placeholder", searcheables[type].title).data("autocomplete", searcheables[type].autocomplete).trigger("flushCache").focus()

    # скритие типов
    $popup.addClass "disabled"

  # включение и отключение выбора типов
  $popup.on "hover", ->
    $search.focus()

  $search.on "keypress", ->
    $popup.addClass "disabled"

  $search.on "click", ->
    if $(".ac_results:visible").length
      $popup.addClass "disabled"
    else
      $popup.toggleClass "disabled"

  $search.on "hover", ->
    $popup.addClass "disabled" if $(".ac_results:visible").length

  $main_search.on "click", (e) ->
    $search.trigger("click").trigger "focus" if $(e.target).hasClass("main-search")

  $main_search.hover_delayed ->
    $main_search.addClass "hovered"
  , ->
    $main_search.removeClass "hovered"
  , 250


# конфигурация автодополнений
searcheables =
  animes:
    title: "Поиск по аниме..."
    autocomplete: "/animes/autocomplete/"
    phrase: "/animes/search/[phrase]"
    id: "/animes/[id]"
    regexp: /.*\/search\/(.*?)\/.*/

  mangas:
    title: "Поиск по манге..."
    autocomplete: "/mangas/autocomplete/"
    phrase: "/mangas/search/[phrase]"
    id: "/mangas/[id]"
    regexp: /.*\/search\/(.*?)\/.*/

  characters:
    title: "Поиск по персонажам..."
    autocomplete: "/characters/autocomplete/"
    phrase: "/characters/search/[phrase]"
    id: "/characters/[id]"
    regexp: /^\/characters\/(.*?)/

  seyu:
    title: "Поиск по сэйю..."
    autocomplete: "/people/autocomplete/seyu/"
    phrase: "/seyu/search/[phrase]"
    id: "/seyu/[id]"
    regexp: /^\/seyu\/(.*?)/

  producers:
    title: "Поиск по режиссёрам..."
    autocomplete: "/people/autocomplete/producer/"
    phrase: "/producers/search/[phrase]"
    id: "/person/[id]"
    regexp: /^\/producer\/(.*?)/

  mangakas:
    title: "Поиск по мангакам..."
    autocomplete: "/people/autocomplete/mangaka/"
    phrase: "/mangakas/search/[phrase]"
    id: "/person/[id]"
    regexp: /^\/mangaka\/(.*?)/

  people:
    title: "Поиск по всем людям..."
    autocomplete: "/people/autocomplete/"
    phrase: "/people/search/[phrase]"
    id: "/person/[id]"
    regexp: /^\/people\/(.*?)/

  users:
    title: "Поиск по пользователям..."
    autocomplete: "/users/autocomplete/"
    phrase: "/users/search/[phrase]"
    id: "/[id]"
    regexp: /^\/users\/(.*?)/
