(($) ->
  $.fn.extend
    shiki_topic: ->
      @each ->
        $root = $(@)
        return unless $root.hasClass('unprocessed')

        new ShikiTopic($root)
) jQuery

class @ShikiTopic extends ShikiEditable
  initialize: ($root) ->
    @$body = @$inner.children('.body')
    @$editor_container = @$('.editor-container')
    @$editor = @$('.b-shiki_editor')
    @editor = new ShikiEditor(@$editor) if @$editor.length # редактора не будет у неавторизованных пользователей
    @is_preview = @$root.hasClass('preview')

    if @is_preview
      @$body.imagesLoaded @_check_height
      @_check_height()

    # ответ на топик
    $('.item-reply', @$inner).on 'click', =>
      reply = if @$root.data 'generated'
        ''
      else
        "[entry=#{@$root.attr('id')}]#{@$root.data 'user_nickname'}[/entry], "

      @$root.trigger 'comment:reply', [reply]

    @$editor
      .on 'ajax:before', (e) ->
        $comment_body = $(@).find('textarea')
        if $comment_body.val().replace(/\n| |\r|\t/g, '') == ''
          $.alert 'Текст комментария не может быть пустым'
          false

      .on 'ajax:success', (e, response) =>
        $new_comment = $(response.html)

        @$('.b-comments').find('.no_comments').remove()
        if @$editor.is(':last-child')
          @$('.b-comments').append $new_comment
        else
          @$('.b-comments').prepend $new_comment

        $new_comment
          .shiki_comment()
          .shiki_message()
          .process()
          .yellowFade()

        @editor.cleanup()
        @_hide_editor()

    # голосование за/против рецензии
    @$('.vote').on 'ajax:before', ->
      $(@).addClass('selected')
      $(@).siblings('.vote').removeClass('selected')

    # прочтение комментриев
    @on 'appear', (e, $appeared, by_click) =>
      $filtered_appeared = $appeared.not ->
        $(@).data('disabled') || !$(@).hasClass('appear-marker')

      if $filtered_appeared.exists()
        interval = if by_click then 1 else 1500
        $objects = $filtered_appeared.closest(".shiki-object")
        $markers = $objects.find('.b-new_marker')
        ids = $objects
          .map ->
            $object = $(@)
            item_type = $object.data('appear_type') || $object.attr('class').match(/b-(\w+)/)[1]
            "#{item_type}-#{@id}"
          .toArray()

        $.ajax
          url: $filtered_appeared.data('appear_url')
          type: 'POST'
          data:
            ids: ids.join ","

        $filtered_appeared.remove()

        $markers.removeClass 'active'
        $markers.css.bind($markers).delay(interval, opacity: 0)
        $markers.hide.bind($markers).delay(interval + 500)

    # ответ на комментарий
    @on 'comment:reply', (e, text, is_offtopic) =>
      @_show_editor()
      @editor.reply_comment text, is_offtopic

    # клик скрытию редактора
    @$('.b-shiki_editor').on 'click', '.hide', @_hide_editor

    # подготовка к подгрузке новых комментов
    @$('.comments-shower').on 'ajax:before', (e, html) ->
      new_url = $(@).data('href-template').replace('SKIP', $(@).data('skip'))
      $(@)
        .data
          href: new_url
          #html: $(@).html()
        #.html("<div class=\"ajax-loading vk-like\" title=\"Загрузка...\" />")

    # подгрузка новых комментов
    @$('.comments-shower').on 'ajax:success', (e, html) =>
      $shower = $(e.target)

      $new_comments = $("<div class='comments-loaded'></div>").html html
      @_filter_present_entries($new_comments)

      $new_comments
        .insertAfter($shower)
        .animated_expand()
        .process()

      if $shower.data 'infinite'
        limit = $shower.data('limit')
        count = $shower.data('count') - limit

        if count > 0
          $shower.data
            skip: $shower.data('skip') + limit
            count: count

          $shower.html "Показать #{p _.min([limit, count]), 'предыдущий', 'предыдущие', 'предыдущие'} #{_.min [limit, count]}&nbsp;#{p count, 'комментарий', 'комментария', 'комментариев'}" + (
              if count > limit then "<span class=\"expandable-comments-count\">&nbsp;(из #{count})</span>" else ""
            )
        else
          $shower.remove()
      else
        $shower
          .html($shower.data 'html') # изначально data 'html' устанавливает обработчик click-loader
          .removeClass('click-loader')
          .hide()
        @$('.comments-hider').show()

    # отображение комментариев
    @$('.comments-shower').on 'click', (e) =>
      unless @$('.comments-shower').is('.click-loader')
        @$('.comments-shower').hide()
        @$('.comments-loaded').animated_expand()
        @$('.comments-hider').show()

    # скрытие комментариев
    @$('.comments-hider').on 'click', (e) =>
      @$('.comments-hider').hide()
      @$('.comments-loaded').animated_collapse()
      @$('.comments-shower').show()

    # realtime обновления
    # изменение / удаление комментария
    @on 'faye:comment:updated faye:message:updated faye:comment:deleted faye:message:deleted', (e, data) =>
      e.stopImmediatePropagation()
      trackable_type = e.type.match(/comment|message/)[0]
      trackable_id = data["#{trackable_type}_id"]

      if e.target == @$root[0]
        @$(".b-#{trackable_type}##{trackable_id}").trigger e.type, data

    # добавление комментария
    @on 'faye:comment:created faye:message:created', (e, data) =>
      e.stopImmediatePropagation()
      trackable_type = e.type.match(/comment|message/)[0]
      trackable_id = data["#{trackable_type}_id"]

      return if @$(".b-#{trackable_type}##{trackable_id}").exists()
      $placeholder = @_faye_placeholder(trackable_id, trackable_type)

      # уведомление о добавленном элементе через faye
      $(document.body).trigger 'faye:added'
      if OPTIONS.comments_auto_loaded
        $placeholder.click() if $placeholder.is(':appeared') && !$('textarea:focus').val()

    # изменение метки комментария
    @on 'faye:comment:marked', (e, data) =>
      e.stopImmediatePropagation()
      $(".b-comment##{data.comment_id}").shiki().mark(data.mark_kind, data.mark_value)

  # удаляем уже имеющиеся подгруженные элементы
  _filter_present_entries: ($comments) ->
    filter = 'b-comment'
    present_ids = $(".#{filter}").toArray().map (v) -> v.id

    exclude_selector = present_ids.map (id) ->
        ".#{filter}##{id}"
      .join(',')

    $comments.children().filter(exclude_selector).remove()

  # отображение редактора, если это превью топика
  _show_editor: ->
    if @is_preview && !@$editor_container.is(':visible')
      @$editor_container.show()#animated_expand()

  # скрытие редактора, если это превью топика
  _hide_editor: =>
    if @is_preview
      @$editor_container.hide()#animated_collapse()

  # получение плейсхолдера для подгрузки новых комментариев
  _faye_placeholder: (trackable_id, trackable_type) ->
    $placeholder = @$('.b-comments .faye-loader')

    unless $placeholder.exists()
      $placeholder = $('<div class="click-loader faye-loader"></div>')
        .appendTo(@$('.b-comments'))
        .data(ids: [])
        .on 'ajax:success', (e, html) ->
          $html = $(html)
          $placeholder.replaceWith $html
          $html
            .shiki_comment()
            .shiki_message()
            .process()

    if $placeholder.data('ids').indexOf(trackable_id) == -1
      $placeholder.data
        ids: $placeholder.data('ids').include(trackable_id)
      $placeholder.data
        href: "/#{trackable_type}s/chosen/#{$placeholder.data("ids").join ","}"

      num = $placeholder.data('ids').length

      $placeholder.html if trackable_type == 'message'
        p(num, "Добавлено #{num} новое сообщение", "Добавлены #{num} новых сообщения", "Добавлено #{num} новых сообщений")
      else
        p(num, "Добавлен #{num} новый комментарий", "Добавлены #{num} новых комментария", "Добавлено #{num} новых комментариев")

    $placeholder

  # проверка высоты топика. урезание, если текст слишком длинный (точно такой же код в shiki_comment)
  _check_height: =>
    @$body.check_height @MAX_PREVIEW_HEIGHT, false, @COLLAPSED_HEIGHT

  _type: -> 'topic'
  _type_label: -> 'Топик'

  # url перезагрузки содержимого
  _reload_url: =>
    "/#{@_type()}s/#{@$root.attr 'id'}/reload/#{@$root.hasClass 'preview'}"
