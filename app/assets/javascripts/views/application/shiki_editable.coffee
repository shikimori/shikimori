import delay from 'delay'

import { getSelectionText, getSelectionHtml } from 'helpers/get_selection'
import axios from 'helpers/axios'
import { animatedCollapse } from 'helpers/animated'

import ShikiView from 'views/application/shiki_view'

export default class ShikiEditable extends ShikiView
  BUTTONS = [
    '.item-ignore'
    '.item-quote'
    '.item-reply'
    '.item-edit'
    '.item-summary'
    '.item-offtopic'
    '.item-cancel'
  ]

  # внутренняя инициализация
  _initialize: ->
    super
    $new_marker = $('.b-new_marker', @$inner)

    # по нажатиям на кнопки закрываем меню в мобильной версии
    @$(BUTTONS.join(','), @$inner).on 'click', =>
      @_close_aside()

    # deletion
    $('.item-delete', @$inner).on 'click', =>
      $('.main-controls', @$inner).hide()
      $('.delete-controls', @$inner).show()

    # confirm deletion
    $('.item-delete-confirm', @$inner).on 'ajax:loading', (e, data, status, xhr) =>
      $.hideCursorMessage()
      animatedCollapse(@root).then => @$root.remove()

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
      $new_marker = $('.b-new_marker.active', @$inner)

      if $new_marker.hasClass('off')
        $new_marker
          .removeClass('off')
          .data(click_activated: true)
          .trigger('reappear')

        axios.post $new_marker.data('reappear_url'), ids: @$root.attr('id')

      else if $new_marker.data('click_activated')
        $new_marker
          .addClass('off')
          .trigger('disappear')

        axios.post $new_marker.data('appear_url'), ids: @$root.attr('id')

      else
        # эвент appear обрабатывается в topic
        $appears = @$('.b-appear_marker.active')
        $appears.trigger 'appear', [$appears, true]

    # realtime уведомление об изменении
    @on "faye:#{@_type()}:updated", (e, data) =>
      $('.was_updated', @$inner).remove()
      message = if @_type() == 'message'
        "#{@_type_label()} #{I18n.t('frontend.shiki_editable.message_changed')}"
      else
        "#{@_type_label()} #{I18n.t('frontend.shiki_editable.changed')}"

      $notice = $("<div class='was_updated'>
        <div><span>#{message}</span><a class='actor b-user16' href='/#{data.actor}'><img src='#{data.actor_avatar}' srcset='#{data.actor_avatar_2x} 2x' /><span>#{data.actor}</span></a>.</div>
        <div>#{I18n.t('frontend.shiki_editable.click_to_reload')}</div>
      </div>")
      $notice
        .appendTo(@$inner)
        .on 'click', (e) =>
          @_reload() unless $(e.target).closest('.actor').exists()
      false # очень важно! иначе эвенты зациклятся из-за такого же обработчика в родителе

    # realtime уведомление об удалении
    @on "faye:#{@_type()}:deleted", (e, data) =>
      message = if @_type() == 'message'
        "#{@_type_label()} #{I18n.t('frontend.shiki_editable.message_deleted')}"
      else
        "#{@_type_label()} #{I18n.t('frontend.shiki_editable.deleted')}"

      @_replace "<div class='b-comment-info b-#{@_type()}'><span>#{message}</span><a class='b-user16' href='/#{data.actor}'><img src='#{data.actor_avatar}' srcset='#{data.actor_avatar_2x} 2x' /><span>#{data.actor}</span></a></div>"
      false # очень важно! иначе эвенты зациклятся из-за такого же обработчика в родителе

  # колбек после инициализации
  _after_initialize: ->
    super()

    if @$body
      # выделение текста в комментарии
      @$body.on 'mouseup', =>
        text = getSelectionText()
        html = getSelectionHtml()
        return unless text || html

        # скрываем все кнопки цитаты
        $('.item-quote').hide()

        @$root.data
          selected_text: text,
          selected_html: html
        $quote = $('.item-quote', @$inner).css(display: 'inline-block')

        delay().then ->
          $(document).one 'click', ->
            unless getSelectionText().length
              $quote.hide()
            else
              delay(250).then ->
                $quote.hide() unless getSelectionText().length

      # цитирование комментария
      $('.item-quote', @$inner).on 'click', (e) =>
        @$root.trigger 'comment:reply', [
          {
            id: @$root.prop('id'),
            type: @_type(),
            user_id: @$root.data('user_id'),
            nickname: @$root.data('user_nickname'),
            text: @$root.data('selected_text'),
            html: @$root.data('selected_html')
          },
          @_is_offtopic?()
        ]

  _activate_appear_marker: ->
    @$inner.children('.b-appear_marker').addClass('active')
    @$inner.children('.markers').find('.b-new_marker').addClass('active')

  # закрытие кнопок в мобильной версии
  _close_aside: ->
    # ">" need because in dialogs we may have nested inner element
    $('> .item-mobile', @$inner).click() if $('.item-mobile', @$inner).is('.selected')

    $('.main-controls', @$inner).show()
    $('.delete-controls', @$inner).hide()
    $('.moderation-controls', @$inner).hide()

  # замена объекта другим объектом
  # _replace: (html) ->
    # $replaced = super html
    # $replaced["shiki_#{@_type()}"]()
    # window.SHIKI_FAYE_LOADER.apply() if @_type() == 'topic'

  # url перезагрузки содержимого
  _reload_url: =>
    "/#{@_type()}s/#{@$root.attr 'id'}"
