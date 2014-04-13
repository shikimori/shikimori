DEFAULT_LIST_SORT = "ranked"

window.AniMangaParamsParser = (base_url, current_url, change_callback, $root) ->
  # вытаскивание из класса элемента типа и значения
  extract_li_info = ($li) ->
    matches = $li.attr("class").match(/([\w\-]+)-([\w.\-]+)/)
    return null unless matches
    type = matches[1]
    value = matches[2]
    if type.match(/genre-\d+/) or type.match(/studio-\d+/) or type.match(/publisher-\d+/) or type.match(/type-\w+/) or type.match(/rating-\w+/) or type.match(/duration-\w+/)
      tmp = type.split("-")
      type = tmp[0]
      value = tmp.slice(1).join("-") + "-" + value
    type: type
    value: value

  # удаление ! из начала и мусора из конца параметра
  remove_bang = (value) ->
    value.replace(/^!/, "").replace /\?.*/, ""

  # добавляет нужный параметр в меню с навигацией
  add_option = (key, value) ->
    # добавляем всегда без !
    value = remove_bang(value)
    text = value.replace(/^\d+-/, "")
    target_year = null
    if key == "publisher" && text.match(/-/)
      text = text.replace(/-/g, " ")
    else if key == "season" && value.match(/^\d+$/)
      target_year = parseInt(value, 10)
      text = value + " год"

    value = value.replace(/\./g, "")
    $li = $("<li class=\"" + key + "-" + value + "\"><input type=\"checkbox\"/>" + text + "</li>")

    # для сезонов вставляем не в начало, а после предыдущего года
    if target_year
      $placeholders = $("ul.seasons li", $root).filter((index) ->
        match = @className.match(/season-(\d+)/)
        return false  unless match
        year = parseInt(match[1], 10)
        year = year * 10  if year < 1000
        year < target_year
      )
      if $placeholders.length
        $li.insertBefore $placeholders.first()
      else
        $(".anime-params." + key + "s", $root).append $li
    else
      $(".anime-params." + key + "s", $root).prepend($li).parent().removeClass "hidden"
    $li

  default_data =
    type: []
    status: []
    season: []
    genre: []
    studio: []
    publisher: []
    duration: []
    rating: []
    options: []
    mylist: []
    search: []
    "order-by": []

  data = $.extend(true, {}, default_data)

  # клики по меню
  $(".anime-params li", $root).live "click", (e) ->
    # игнор средней кнопки мыши
    return  if in_new_tab(e)
    $this = $(this)
    already_selected = $this.hasClass("selected")
    li_info = extract_li_info($this)
    return true  unless li_info
    unless already_selected
      if "type" of e.target and e.target.type is "checkbox"
        params.add li_info.type, li_info.value
      else
        params.set li_info.type, li_info.value
    else
      params.remove li_info.type, li_info.value

    change_callback params.compile()
    false  unless "type" of e.target and e.target.type is "checkbox"

  # клики по фильтру группы - плюсику или минусику
  $(".anime-params-block .block-filter", $root).live "click", (e) ->
    $this = $(this)
    to_exclude = $this.hasClass("item-add")
    $this.removeClass((if to_exclude then "item-add" else "item-minus")).addClass (if not to_exclude then "item-add" else "item-minus")
    $this.closest(".anime-params-block").find("li").map(->
      extract_li_info $(this)
    ).each (index, li_info) ->
      data[li_info.type][index] = (if to_exclude then "!" + li_info.value else li_info.value)

    change_callback params.compile()
    params.parse params.compile()

  # клики по фильтру элемента - плюсику или минусику
  $(".anime-params li .filter", $root).live "click", (e) ->
    $this = $(this)
    to_exclude = $this.hasClass("item-add")
    $this.removeClass((if to_exclude then "item-add" else "item-minus")).addClass (if not to_exclude then "item-add" else "item-minus")
    li_info = extract_li_info($this.parent())
    value_key = _.indexOf(data[li_info.type], (if to_exclude then li_info.value else "!" + li_info.value))
    data[li_info.type][value_key] = (if to_exclude then "!" + li_info.value else li_info.value)
    change_callback params.compile()
    false

  # клики по тегам на странице
  $(".type.tag-base,.studio.tag-base,.publisher.tag-base,.genre.tag-base,.season.tag-base").live "click", (e) ->
    type = $(@).data("type")
    value = String($(@).data("value"))
    $node = $("li.#{type}-#{value}")
    $node = add_option(type, value)  unless $node.length
    $node.trigger "click"
    false

  params =
    data: ->
      data

    # установка значения параметра
    set: (key, value) ->
      self = this
      _.each data[key], (value) ->
        self.remove key, value

      @add key, value

    # выбор элемента
    add: (key, value) ->
      if key is _.last(_.keys(data)) and data[key].length > 0
        @set key, value
      else
        data[key].push value
      $li = $("li." + key + "-" + remove_bang(value), $root)

      # если такого элемента нет, то создаем его
      $li = add_option(key, value)  unless $li.length

      # если элемент есть, но скрыт, то показываем его
      $li.css "display", "block"  if $li.css("display") is "none"
      $li.addClass "selected"

      # если элемент с чекбоксом, то ставим галочку на чекбокс
      $input = $li.children("input")
      if $input.length
        $input.attr "checked", true

        # добавляем или показываем плюсик
        $filter = $li.children(".filter")
        if $filter.length
          $filter.removeClass("item-add").removeClass("item-minus").addClass((if value[0] is "!" then "item-minus" else "item-add")).show()
        else
          $li.prepend "<span class=\"filter " + ((if value[0] is "!" then "item-minus" else "item-add")) + "\"></span>"

    # отмена выбора элемента
    remove: (key, value) ->
      # т.к. сюда значение приходит как с !, так и без, то удалять надо оба варианта
      value = remove_bang(value)
      data[key] = _.without(_.without(data[key], value), "!" + value)
      $li = $("." + key + "-" + value, $root)
      $li.removeClass "selected"

      # снятие галочки с чекбокса
      $li.children("input").attr "checked", false

      # скрытие плюсика/минусика
      $li.children(".filter").hide()

    # формирование строки урла по выбранным элементам
    compile: ->
      @last_compiled = base_url + _.map(data, (values, key) -> #.replace('/order-by/ranked', '');
        if _.isArray(values)
          if values.length
            "/" + key + "/" + values.join(",")
          else
            null
        else
          "/" + key + "/" + values
      ).join("")
      @last_compiled

    last_compiled: null

    # парсинг строки урла и выбор
    parse: (url) ->
      $(".anime-params .selected", $root).toggleClass "selected"
      $(".anime-params input[type=checkbox]:checked", $root).attr "checked", false
      $(".anime-params .filter", $root).hide()
      self = this
      data = $.extend(true, {}, default_data)
      parts = url
        .replace("#{location.protocol}//#{location.hostname}", '')
        .replace(base_url, "")
        .match(/[\w\-]+\/[^\/]+/g)

      _.each parts || [], (match) ->
        key = match.split("/")[0]
        return if key == "page" || (key not of default_data)
        values = match.split("/")[1].split(",")
        _.each values, _.bind(self.add, self, key)

  params.parse current_url
  params
