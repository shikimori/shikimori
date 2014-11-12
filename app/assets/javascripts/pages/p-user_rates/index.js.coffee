# TODO: этот гигантский файл нуждается в рефакторинге
list_cache = []
filter_timer = null

@on 'page:load', 'user_rates_index', ->
  apply_list_handlers $('.b-user_rates')
  update_list_cache()

  # фокус по инпуту фильтра по тайтлу
  $('.filter input').on 'focus', ->
    update_list_cache() unless list_cache.length

  # разворачивание свёрнутых блоков при фокусе на инпут
  $('.filter input').on 'focus', ->
    $('.collapsed').each ->
      $(@).trigger 'click' if @style.display == 'block'

  # пишут в инпуте фильтра по тайтлу
  $('.filter input').on 'keyup', (e) ->
    return if e.keyCode == 91 || e.keyCode == 18 || e.keyCode == 16 || e.keyCode == 17

    if filter_timer
      clearInterval filter_timer
      filter_timer = null

    filter_timer = setInterval filter, 350

  # клик разделам списка в b-options-floated блоке
  $('.b-options-floated.mylist .link').on 'click', ->
    $(".anime-params.mylist .mylist-#{$(@).data 'id'}").click()

  base_catalog_path = location.pathname.replace(/(\/list\/(?:anime|manga))(\/.+)?/, '$1')
  new AnimeCatalogFilters base_catalog_path, location.href, (url) ->
    Turbolinks.visit url, true
    if $('.l-page.menu-expanded').exists()
      $(document).one 'page:change', -> $('.l-page').addClass('menu-expanded')

# фильтрация списка пользователя
filter = ->
  clearInterval filter_timer
  filter_timer = null

  # разворачивание свёрнутых элементов
  filter_value = $('.filter input').val().toLowerCase()
  $entries = $('tr.selectable')
  _(list_cache).each (block) ->
    visible = false
    i = 0

    while i < block.rows.length
      entry = block.rows[i]
      if entry.title.indexOf(filter_value) >= 0
        visible = true

        if entry.display != ''
          entry.display = ''
          entry.node.style.display = ''

      else if entry.display != 'none'
        entry.display = 'none'
        entry.node.style.display = 'none'
      i++

    block.$nodes.toggle visible  if block.toggable
    block.$only_show.show() if block.$only_show and visible
    return

  $.force_appear()

# кеширование всех строчек списка для производительности
update_list_cache = ->
  list_cache = $('table').map ->
    $table = $(@)
    rows = $table.find('tr.selectable').map(->
      node: @
      title: String($(@).data('title')).toLowerCase()
      display: @style.display
    ).toArray()
    $nodes = $table.add($table.prev(':not(.collapse-merged)'))

    # если текущая таблица подгружена пагинацией, тоесть она без заголовка, то...
    if $nodes.length is 1
      klass = $table.prev().attr('class').match(/status-\d/)[0]
      $only_show = $(".#{klass}:not(.collapse-merged)")
      $only_show = $only_show.add($only_show.next())

    $nodes: $nodes
    $only_show: $only_show
    rows: rows
    toggable: !$table.next('.b-postloader').length


# обработчики для списка
apply_list_handlers = ($root) ->
  # хендлер подгрузки очередной страницы
  $('.b-postloader').on 'postloader:success', insert_next_page

  # открытие блока с редактирование записи по клику на строку с аниме
  $('tr.editable', $root).on 'click', (e) ->
    if $(@).next().hasClass 'edit-form'
      $(@).next().find('.cancel').click()
      e.stopImmediatePropagation()
  $('tr.editable', $root).on 'ajax:success', (e, html) ->
    # прочие блоки редактирования скроем
    $another_tr_edit = $('tr.edit-form')

    $tr = $(@)
    $tr_edit = $("<tr class='edit-form'><td colspan='#{$(@).children('td').length}'>#{html}</td></tr>").insertAfter(@)
    $form = $tr_edit.find('form')
    #original_height = $form.height()

    if $another_tr_edit.exists()
      $another_tr_edit.remove()
    else
      $form.animated_expand()
      #$form.css height: 0
      #(-> $form.css height: original_height).delay()

    # отмена редактирования
    $('.cancel', $tr_edit).on 'click', ->
      $form.animated_collapse()
      $tr_edit.remove.bind($tr_edit).delay(550)

    # применение изменений в редактировании
    $form.on 'ajax:success', (e, data) ->
      $.flash notice: 'Изменения сохранены'
      $('.cancel', $tr_edit).click()

      $('.current-value[data-field=score]', $tr).html String(data.score || '0').replace(/^0$/, '–')
      $('.current-value[data-field=chapters]', $tr).html data.chapters
      $('.current-value[data-field=volumes]', $tr).html data.volumes
      $('.current-value[data-field=episodes]', $tr).html data.episodes
      $('.rate-text', $tr).html if data.text_html then "<div>#{data.text_html}</div>" else ''
      if data.rewatches > 0
        $('.rewatches', $tr).html(if data.anime then "#{data.rewatches} #{p data.rewatches, 'повторный просмотр', 'повторных просмотра', 'повторных просмотров'}" else "#{data.rewatches} #{p data.rewatches, 'повторное прочтение', 'повторных прочтения', 'повторных прочтений'}")
      else
        $('.rewatches', $tr).html ''

    # удаление из списка
    $('.remove', $form).on 'ajax:success', (e, data) ->
      $('.cancel', $tr_edit).click()
      (-> $tr.remove()).delay 250
      e.stopPropagation()

  $('tr.unprocessed', $root)
    .removeClass('unprocessed')
    .find('a.tooltipped')
    .tooltip $.extend($.extend({}, tooltip_options),
      offset: [
        -95
        10
      ]
      position: 'bottom right'
      opacity: 1
      onBeforeShow: null
      onBeforeHide: null
    )

  # изменения оценки/числа просмотренных эпизодов
  $trs = $('.b-user_rates .hoverable').off()
  $trs.off()
    .hover ->
        return if is_mobile()
        $current_value = $('.current-value', @)
        $new_value = $('.new-value', @)

        # если нет элемента, то создаём его
        if $new_value.length is 0
          val = parseInt $current_value.text(), 10
          val = 0 if !val && val != 0

          new_value_html = if $current_value.data('field') != 'score'
            "<span class=\"new-value\"><input type=\"text\" class=\"input\"/><span class=\"item-add\"></span></span>"
          else
            "<span class=\"new-value\"><input type=\"text\" class=\"input\"/></span>"

          $new_value = $(new_value_html)
            .children('input')
            .val(val)
            .data(counter: val, max: $current_value.data('max') || 999, min: $current_value.data('min'))
            .data(field: $current_value.data('field'), action: $current_value.closest('tr').data('rate_url'))
              .parent()
              .insertAfter($current_value)

          apply_new_value_handlers $new_value

        $new_value.show()
        $current_value.hide()
        $('.misc-value', @).hide()

      , ->
        return if is_mobile()
        return if $('.new-value input', @).is(":focus")
        $('.new-value', @).hide()
        $('.current-value', @).show()
        $('.misc-value', @).show()

    .on 'click', (e) ->
      return if is_mobile()
      # клик на плюсик обрабатываем по дефолтному
      return if e.target && e.target.className == 'item-add'
      $this = $(@)
      $this.trigger 'mouseenter'
      $('input', $this).trigger('focus').select()
      e.stopPropagation()
      false


apply_new_value_handlers = ($new_value) ->
  # обработчики для инпутов листа
  $('input', $new_value).off()
    .on 'blur', ->
      $this = $(@)
      $this.parent().parent().trigger 'mouseleave'
      @value = 0 if @value < 0
      return if (parseInt(@value, 10) or 0) is (parseInt($this.data('counter'), 10) or 0)

      $value = $this.parent().parent().find('.current-value')
      prior_value = $value.html()
      $this.data 'counter', @value
      $value.html (if $this.data('counter') == '0' then '&ndash;' else $this.data('counter'))

      $.post($this.data('action'), "_method=patch&user_rate[#{$this.data 'field'}]=#{$this.attr 'value'}")
        .error ->
          $value.html prior_value
          $.flash alert: 'Произошла ошибка'

    .on 'mousewheel', (e) ->
      return true unless $(@).is(':focus')

      if e.originalEvent.wheelDelta && e.originalEvent.wheelDelta > 0
        @value = Math.min (parseInt(@value, 10) + 1 or 0), parseInt($(@).data('max'), 10)

      else if e.originalEvent.wheelDelta
        @value = Math.max (parseInt(@value, 10) - 1 or 0), parseInt($(@).data('min'), 10)

      false

    .on 'keydown', (e) ->
      if e.keyCode is 38
        @value = Math.min (parseInt(@value, 10) + 1 or 0), parseInt($(@).data('max'), 10)

      else if e.keyCode is 40
        @value = Math.max (parseInt(@value, 10) - 1 or 0), parseInt($(@).data('min'), 10)

      else if e.keyCode is 27
        @value = $(@).data('counter')
        $(@).trigger 'blur'

    .on 'keypress', (e) ->
      if e.keyCode is 13
        $(@).trigger 'blur'
        e.stopPropagation()
        false

  # обработчик для плюсика у числа эпизодов/глав
  $('.item-add', $new_value).on 'click', (e) ->
    $input = $(@).prev()
    $input
      .val(parseInt($input.val(), 10) + 1)
      .triggerWithReturn('blur')
      .success(-> $input.closest('td').trigger 'mouseover')

    e.stopPropagation()
    false

# подгрузка очередной страницы списка
insert_next_page = (e, $data) ->
  $header = $data.find('header:first')

  # при подгрузке могут быть 2 случая:
  # 1. подгружается совершенно новый блок, и тогда $header будет пустым
  # 2. погружается дальнейший контент уже существующего блока, и тогда...
  if $("header.#{$header.attr 'class'}").exists()
    # заголовок скрываем, ставим ему класс collapse-merged и collapse-ignored(чтобы раскрытие collapsed работало корректно),
    # а так же таблице ставим класс merged и скрываем её заголовок
    $header
      .addClass('collapse-merged')
      .addClass('collapse-ignored')
      .hide()
        .next()
        .addClass('collapse-merged')
          .find('tr:first,tr.border')
          .hide()

  (->
    apply_list_handlers $data

    update_list_cache()
    $input = $('.filter input')
    $input.trigger('keyup') unless _.isEmpty($input.val())
  ).delay 250
