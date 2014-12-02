class @ShikiEditable extends ShikiView
  # внутренняя инициализация
  _initialize: ($root) ->
    super $root

    # cancel control in mobile expanded aside
    $('.item-cancel', @$inner).on 'click', =>
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
    $('.b-new_marker', @$inner).on 'click', =>
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

    # realtime уведомление об удалении
    @on "faye:#{@_type()}:deleted", (e, data) =>
      message = if @_type() == 'message'
        "#{@_type_label()} удалено пользователем"
      else
        "#{@_type_label()} удалён пользователем"

      @_replace "<div class='b-comment-info b-#{@_type()}'><span>#{message}</span><a class='b-user16' href='/#{data.actor}'><img src='#{data.actor_avatar}' srcset='#{data.actor_avatar_2x} 2x' /><span>#{data.actor}</span></a></div>"

  # закрытие кнопок в мобильной версии
  _close_aside: ->
    $('.item-mobile', @$inner).click() if $('.item-mobile', @$inner).is('.selected')

    $('.main-controls', @$inner).show()
    $('.delete-controls', @$inner).hide()
    $('.moderation-controls', @$inner).hide()

  # замена объекта другим объектом
  _replace: (html) ->
    $replaced = $(html)
    @$root.replaceWith($replaced)

    $replaced.process()
    $replaced["shiki_#{@_type()}"]()
    $replaced.yellowFade()

  # перезагрузка содержимого
  _reload: =>
    @$root.addClass 'ajax:request'
    $.get "/#{@_type()}s/#{@$root.attr 'id'}", (response) =>
      @_replace response
