# TODO: refactor to normal classes
import inNewTab from 'helpers/in_new_tab'
import urlParse from 'url-parse'
import URI from 'urijs'

DEFAULT_ORDER = 'ranked'
DEFAULT_DATA =
  kind: []
  status: []
  season: []
  franchise: []
  achievement: []
  genre: []
  studio: []
  publisher: []
  duration: []
  rating: []
  score: []
  options: []
  mylist: []
  'order-by': []
  licensor: []

GET_FILTERS = ['licensor']

export default (base_path, current_url, change_callback) ->
  $root = $('.b-collection-filters')

  # вытаскивание из класса элемента типа и значения
  extract_li_info = ($li) ->
    field = $li.data('field')
    value = $li.data('value')
    return null unless field && value

    field: field
    value: String(value)

  # удаление ! из начала и мусора из конца параметра
  remove_bang = (value) ->
    value.replace(/^!/, '').replace /\?.*/, ''

  # добавляет нужный параметр в меню с навигацией
  add_option = (field, value) ->
    # добавляем всегда без !
    value = remove_bang(value)
    text = value.replace(/^\d+-/, '')
    target_year = null

    if (field == 'publisher' || field == 'studio') && text.match(/-/)
      text = text.replace(/-/g, ' ')
    else if field == 'season' && value.match(/^\d+$/)
      target_year = parseInt(value, 10)
      text = value + ' год'
    else if field == 'licensor'
      text = value

    value = value.replace(/\./g, '')
    $li = $("<li data-field='#{field}' data-value='#{value}'><input type='checkbox'/>#{text}</li>")

    # для сезонов вставляем не в начало, а после предыдущего года
    if target_year
      $placeholders = $('ul.seasons li', $root).filter((index) ->
        match = @className.match(/season-(\d+)/)
        return false unless match
        year = parseInt(match[1], 10)
        year = year * 10 if year < 1000
        year < target_year
      )
      if $placeholders.length
        $li.insertBefore $placeholders.first()
      else
        $(".anime-params.#{field}s", $root).append $li
    else
      $(".anime-params.#{field}s", $root).prepend($li).parent().removeClass 'hidden'
    $li

  # клики по меню
  $('.anime-params', $root).on 'click', 'li', (e) ->
    return if inNewTab(e) # игнор средней кнопки мыши
    return if e.target.classList.contains('b-question') # игнор при клике на инфо блок
    #return if $(e.target).hasClass('filter') # игнор при клике на фильтр

    already_selected = @classList.contains 'selected'

    li_info = extract_li_info $(@)
    return true unless li_info

    unless already_selected
      if 'type' of e.target && e.target.type == 'checkbox'
        filters.add li_info.field, li_info.value
      else
        filters.set li_info.field, li_info.value
    else
      filters.remove li_info.field, li_info.value

    change_callback filters.compile()
    false unless 'type' of e.target && e.target.type == 'checkbox'

  # клики по фильтру группы - плюсику или минусику
  $('.anime-params-block .block-filter', $root).on 'click', (e) ->
    $params_block = $(@).closest('.anime-params-block')

    to_exclude =
      if $(@).hasClass('item-sign')
        $params_block.find('li').length == $params_block.find('.item-add:visible').length
      else
        $(@).hasClass('item-add')

    to_disable = $(@).hasClass('item-sign') &&
      $params_block.find('li').length == $params_block.find('.item-minus:visible').length

    $params_block
      .find('li')
      .map(-> extract_li_info $(@))
      .each (index, li_info) ->
        if to_disable
          filters.params[li_info.field] = []
        else
          filters.params[li_info.field][index] = (
            if to_exclude then '!' + li_info.value else li_info.value
          )

    change_callback filters.compile()
    filters.parse filters.compile()

  # клики по фильтру элемента - плюсику или минусику
  $('.anime-params li', $root).on 'click', '.filter', (e) ->
    to_exclude = $(@).hasClass('item-add')

    $(@)
      .removeClass((if to_exclude then 'item-add' else 'item-minus'))
      .addClass (if not to_exclude then 'item-add' else 'item-minus')

    li_info = extract_li_info $(@).parent()
    value_key = filters.params[li_info.field].indexOf(
      if to_exclude then li_info.value else '!' + li_info.value
    )
    filters.params[li_info.field][value_key] =
      (if to_exclude then '!' + li_info.value else li_info.value)
    change_callback filters.compile()
    false

  filters =
    params: null

    # установка значения параметра
    set: (field, value) ->
      self = this
      @params[field].forEach (value) ->
        self.remove field, value

      @add field, value

    # выбор элемента
    add: (field, value) ->
      if field is Object.keys(@params).last() && @params[field].length > 0
        @set field, value
      else
        @params[field].push value

      $li = $("li[data-field='#{field}'][data-value='#{remove_bang value}']", $root)

      # если такого элемента нет, то создаем его
      $li = add_option(field, value)  unless $li.length

      # если элемент есть, но скрыт, то показываем его
      $li.css display: 'block' if $li.css('display') == 'none'
      $li.addClass 'selected'

      # если элемент с чекбоксом, то ставим галочку на чекбокс
      $input = $li.children('input')
      if $input.length
        $input.prop checked: true

        # добавляем или показываем плюсик
        $filter = $li.children('.filter')
        if $filter.length
          $filter
            .removeClass('item-add')
            .removeClass('item-minus')
            .addClass((if value[0] is '!' then 'item-minus' else 'item-add')).show()
        else
          $li.prepend(
            '<span class="filter ' +
              ((if value[0] is '!' then 'item-minus' else 'item-add')) +
              '"></span>'
          )

    # отмена выбора элемента
    remove: (field, value) ->
      # т.к. сюда значение приходит как с !, так и без, то удалять надо оба варианта
      value = remove_bang(value)
      @params[field] = @params[field].subtract([value, "!#{value}"])

      try # because there can bad order, and it will break jQuery selector
        $li = $("li[data-field='#{field}'][data-value='#{value}']", $root)
        $li.removeClass 'selected'

        # снятие галочки с чекбокса
        $li.children('input').prop checked: false

        # скрытие плюсика/минусика
        $li.children('.filter').hide()

    # формирование строки урла по выбранным элементам
    compile: (page) ->
      path_filters = ''
      location_filters = urlParse(window.location.href, true).query

      Object.forEach @params, (values, field) ->
        if GET_FILTERS.includes(field)
          if values?.length
            location_filters[field] = values.join(',')
          else
            delete location_filters[field]

        else if values?.length
          if field == 'order-by' && values[0] == DEFAULT_ORDER &&
              !location.href.match(/\/list\/(anime|manga)/)
            return

          path_filters += "/#{field}/#{values.join ','}"

      if page && page != 1
        path_filters += "/page/#{page}"

      @last_compiled = URI(base_path + path_filters).query(location_filters).toString()

    last_compiled: null

    # парсинг строки урла и выбор
    parse: (url) ->
      $('.anime-params .selected', $root).toggleClass 'selected'
      $('.anime-params input[type=checkbox]:checked', $root).prop checked: false
      $('.anime-params .filter', $root).hide()

      @params = JSON.parse(JSON.stringify(DEFAULT_DATA))
      parts = url
        .replace("#{location.protocol}//#{location.hostname}", '')
        .replace(":#{location.port}", '')
        .replace(base_path, '')
        .replace(/\?.*/, '')
        .match(/[\w\-]+\/[^\/]+/g)

      uri_query = urlParse(window.location.href, true).query

      if uri_query.licensor
        parts = (parts || []).concat ["licensor/#{uri_query.licensor}"]

      (parts || []).forEach (match) =>
        field = match.split('/')[0]
        return if field == 'page' || (field not of DEFAULT_DATA)

        match
          .split('/')[1]
          .split(',')
          .forEach (value) =>
            try
              @add field, value
            catch # becase there can bad order, and it will break jQuery selector
              if field == 'order-by'
                @add 'order-by', DEFAULT_ORDER

      if Object.isEmpty(@params['order-by'])
        @add 'order-by', DEFAULT_ORDER

  filters.parse current_url

  # раскрываем фильтры, если какой-то из них выбран
  if filters.params.genre.length
    $root.find('.genres .b-spoiler').spoiler().trigger('spoiler:open')

  if filters.params.licensor.length
    $root.find('.licensors .b-spoiler').spoiler().trigger('spoiler:open')

  filters
