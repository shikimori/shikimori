class @ShikiEditable extends ShikiView
  # внутренняя инициализация
  _initialize: ($root) ->
    super $root
    $new_marker = $('.b-new_marker', @$inner)

    # по нажатиям на кнопки закрываем меню в мобильной версии
    @$('.item-ignore, .item-quote, .item-reply, .item-edit, .item-summary,
        .item-offtopic, .item-cancel', @$inner).on 'click', =>
      @_close_aside()

    # deletion
    $('.item-delete', @$inner).on 'click', =>
      $('.main-controls', @$inner).hide()
      $('.delete-controls', @$inner).show()

    # confirm deletion
    $('.item-delete-confirm', @$inner).on 'ajax:loading', (e, data, status, xhr) =>
      $.hideCursorMessage()
      @$root
        .animated_collapse()
        .remove.bind(@$root).delay(500)

    # cancel deletion
    $('.item-delete-cancel', @$inner).on 'click', =>
      #@$('.main-controls').show()
      #@$('.delete-controls').hide()
      @_close_aside()

    # переключение на мобильую версию кнопок кнопок
    $('.item-mobile', @$inner).on 'click', =>
      @$root.toggleClass('aside-expanded')
      $('.item-mobile', @$inner).toggleClass('selected')
      # из-за снятия overflow для элемента с .aside-expanded, сокращённая высота работает некорректно, поэтому её надо убрать
      @$root.find('>.b-height_shortener').click()

    # по клику на 'новое' пометка прочитанным
    $new_marker.on 'click', =>
      if $('.b-new_marker', @$inner).hasClass('off')
        $new_marker.removeClass('off').data(manual: true)
        $.ajax
          url: $new_marker.data 'reappear_url'
          type: 'POST'
          data:
            ids: $root.attr('id')

      else if $('.b-new_marker', @$inner).data('manual')
        $new_marker.addClass('off')
        $.ajax
          url: $new_marker.data 'appear_url'
          type: 'POST'
          data:
            ids: $root.attr('id')

      else
        # эвент appear обрабатывается в shiki-topic
        @$('.appear-marker').trigger 'appear', [@$('.appear-marker'), true]

    # realtime уведомление об изменении
    @on "faye:#{@_type()}:updated", (e, data) =>
      $('.was_updated', @$inner).remove()
      message = if @_type() == 'message'
        "#{@_type_label()} изменено пользователем"
      else
        "#{@_type_label()} изменён пользователем"

      $notice = $("<div class='was_updated'>
        <div><span>#{message}</span><a class='actor b-user16' href='/#{data.actor}'><img src='#{data.actor_avatar}' srcset='#{data.actor_avatar_2x} 2x' /><span>#{data.actor}</span></a>.</div>
        <div>Кликните для обновления.</div>
      </div>")
      $notice
        .appendTo(@$inner)
        .on 'click', (e) =>
          @_reload() unless $(e.target).closest('.actor').exists()
      false # очень важно! иначе эвенты зациклятся из-за такого же обработчика в родителе

    # realtime уведомление об удалении
    @on "faye:#{@_type()}:deleted", (e, data) =>
      message = if @_type() == 'message'
        "#{@_type_label()} удалено пользователем"
      else
        "#{@_type_label()} удалён пользователем"

      @_replace "<div class='b-comment-info b-#{@_type()}'><span>#{message}</span><a class='b-user16' href='/#{data.actor}'><img src='#{data.actor_avatar}' srcset='#{data.actor_avatar_2x} 2x' /><span>#{data.actor}</span></a></div>"
      false # очень важно! иначе эвенты зациклятся из-за такого же обработчика в родителе

  # колбек после инициализации
  _after_initialize: ->
    super()

    if @$body
      # выделение текста в комментарии
      @$body.on 'mouseup', =>
        text = $.getSelectionText()
        return unless text

        # скрываем все кнопки цитаты
        $('.item-quote').hide()

        @$root.data(selected_text: text)
        $quote = $('.item-quote', @$inner).css(display: 'inline-block')

        _.delay ->
          $(document).one 'click', ->
            unless $.getSelectionText().length
              $quote.hide()
            else
              _.delay ->
                $quote.hide() unless $.getSelectionText().length
              , 250

      # цитирование комментария
      $('.item-quote', @$inner).on 'click', (e) =>
        ids = [@$root.prop('id'), @$root.data('user_id'), @$root.data('user_nickname')]
        selected_text = @$root.data('selected_text')
        type = @_type()[0]
        quote = "[quote=#{type}#{ids.join ';'}]#{selected_text}[/quote]\n"

        @$root.trigger 'comment:reply', [quote, @_is_offtopic?()]

  # закрытие кнопок в мобильной версии
  _close_aside: ->
    $('.item-mobile', @$inner).click() if $('.item-mobile', @$inner).is('.selected')

    $('.main-controls', @$inner).show()
    $('.delete-controls', @$inner).hide()
    $('.moderation-controls', @$inner).hide()

  # замена объекта другим объектом
  _replace: (html) ->
    $replaced = super html
    $replaced["shiki_#{@_type()}"]()
    window.faye_loader.apply() if @_type() == 'topic'

  # url перезагрузки содержимого
  _reload_url: =>
    "/#{@_type()}s/#{@$root.attr 'id'}"
