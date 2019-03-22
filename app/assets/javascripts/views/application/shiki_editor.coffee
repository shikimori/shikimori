import delay from 'delay'
import autosize from 'autosize'

import axios from 'helpers/axios'
import ShikiView from 'views/application/shiki_view'

import { mobileDetect } from 'helpers/mobile_detect'
import flash from 'services/flash'

isMobile = mobileDetect.isMobile
isTablet = mobileDetect.isTablet

# TODO: refactor constructor
export default class ShikiEditor extends ShikiView
  initialize: ->
    $root = @$root
    @$form = @$('form')

    if @$form.exists()
      @is_inner_form = true
    else
      @$form = $root.closest('form')
      @is_inner_form = false

    @$textarea = @$('textarea')

    # при вызове фокуса на shiki-editor передача сообщения в редактор
    @on 'focus', => @$textarea.trigger('focus')

    # по первому фокусу на редактор включаем autosize
    @$textarea.one 'focus', =>
      delay().then => autosize @$textarea[0]

    @$textarea.on 'keypress keydown', (e) =>
      if e.keyCode == 27 # esc
        @$textarea.blur()
        false

      else if e.metaKey || e.ctrlKey
        # сохранение по ctrl+enter
        if e.keyCode == 10 || e.keyCode == 13
          @$form.submit()
          false

        # [b] tag
        # else if e.keyCode == 98 || e.keyCode == 66
        else if e.keyCode == 66 # b
          @$('.editor-bold').click()
          false

        # [i] tag
        # else if e.keyCode == 105 || e.keyCode == 73
        else if e.keyCode == 73 # i
          @$('.editor-italic').click()
          false

        # [u] tag
        # else if e.keyCode == 117 || e.keyCode == 85
        else if e.keyCode == 85 # u
          @$('.editor-underline').click()
          false

        # spoiler tag
        # else if e.keyCode == 115 || e.keyCode == 83
        else if e.keyCode == 83 # s
          @$('.editor-spoiler').click()
          false

        # code tag
        else if e.keyCode == 79 # o
          @$textarea.insertAtCaret '[code]', '[/code]'
          false

    @$form
      .on 'ajax:before', =>
        if @$textarea.val().replace(/\n| |\r|\t/g, '')
          @_shade()
        else
          flash.error I18n.t('frontend.shiki_editor.text_cant_be_blank')
          false

      .on 'ajax:complete', @_unshade
      .on 'ajax:success', =>
        @_hide_preview()
        delay().then =>
          @$textarea[0].dispatchEvent(new Event('autosize:update'))

    # при клике на неselected кнопку, закрываем все остальные selected кнопки
    @$('.editor-controls span').on 'click', (e) =>
      unless $(e.target).hasClass('selected')
        @$('.editor-controls span.selected').trigger('click')

    # бб коды
    @$('.editor-bold').on 'click', =>
      @$textarea.insertAtCaret '[b]', '[/b]'

    @$('.editor-italic').on 'click', =>
      @$textarea.insertAtCaret '[i]', '[/i]'

    @$('.editor-underline').on 'click', =>
      @$textarea.insertAtCaret '[u]', '[/u]'

    @$('.editor-strike').on 'click', =>
      @$textarea.insertAtCaret '[s]', '[/s]'

    @$('.editor-spoiler').on 'click', =>
      @$textarea.insertAtCaret(
        "[spoiler=#{I18n.t 'frontend.shiki_editor.spoiler'}]", '[/spoiler]'
      )

    # смайлики и ссылка
    ['smiley', 'link', 'image', 'quote', 'upload'].forEach (key) =>
      @$(".editor-#{key}").on 'click', (e) =>
        $button = $(e.target)
        $block = @$(".#{key}s")

        if $button.hasClass('selected')
          $block.animatedCollapse()
        else
          $block.animatedExpand()
          $block.trigger('click:open')

        $button.toggleClass('selected')

    # кнопка сабмита OK
    @$('.b-button.ok').on 'click', (e) =>
      type = $(e.target).data('type')

      $input = @$(".#{type} input[type=text]")
      if type == 'images'
        $input.trigger 'keypress', [true]
      else
        $input.trigger 'autocomplete:text', [$input.val()]

    # открытие блока ссылки
    @$('.links').on 'click:open', =>
      @$('.links input[type=text]').val('')
      @$('#link_type_url')
        .attr(checked: true)
        .trigger('change')

    # автокомплит для поля ввода ссылки
    @$('.links input[type=text]')
      .completable()
      .on 'autocomplete:success autocomplete:text',  (e, result) =>
        $radio = @$('.links input[type=radio]:checked')
        radio_type = $radio.prop('id').replace('link_type_', '')

        param = if Object.isString(result)
          if radio_type == 'url'
            result
        else
          id: result.id
          text: result.name
          type: radio_type

        $radio.trigger("tag:build", param) if param

    # изменение типа ссылки
    @$('.links input[type=radio]').on 'change', ->
      $this = $(@)
      $input = $('.links input[type=text]', $root)
      $input.attr placeholder: $this.data('placeholder') # меняем плейсхолдер

      if $this.data('autocomplete')
        $input.data autocomplete: $this.data('autocomplete') # устанавливаем урл для автокомплита
      else
        $input.data autocomplete: null

      # чистим кеш автокомплита
      #.attr('value', '') // чистим текущий введённый текст
      $input.trigger('flushCache').focus()

    # общий обработчик для всех радио кнопок, закрывающий блок со ссылками
    @$('.links input[type=radio]').on 'tag:build', (e, data) =>
      @$('.editor-link').trigger('click')

    # открытие блока картинки
    @$('.images').on 'click:open', =>
      # чистим текущий введённый текст
      @$('.images input[type=text]').val('').focus()

    # сабмит картинки в текстовом поле
    @$('.images input[type=text]').on 'keypress', (e, force_submit) =>
      if e.keyCode is 10 || e.keyCode is 13 || force_submit
        @$textarea.insertAtCaret '', "[img]#{$(e.target).val()}[/img]"
        @$('.editor-image').trigger('click')
        false

    # открытие блока цитаты
    @$('.quotes').on 'click:open', =>
      # чистим текущий введённый текст
      @$('.quotes input[type=text]').val('').focus()

    # сабмит цитаты в текстовом поле
    @$('.quotes input[type=text]').on 'keypress', (e) =>
      if e.keyCode is 10 || e.keyCode is 13
        @$textarea.insertAtCaret(
          '[quote' +
            ((if not @value or @value.isBlank() then "" else "=" + @value)) +
            ']',
          '[/quote]'
        )
        @$('.editor-quote').trigger('click')
        false

    # автокомплит для поля ввода цитаты
    @$(".quotes input[type=text]")
      .completable()
      .on 'autocomplete:success autocomplete:text', (e, result) =>
        text = if Object.isString(result) then result else result.value
        @$textarea.insertAtCaret(
          '[quote' +
            (if not text or text.isBlank() then "" else "=" + text) + ']',
            '[/quote]'
        )
        @$(".editor-quote").trigger('click')

    # построение бб-кода для url
    @$('.links #link_type_url').on 'tag:build', (e, value) =>
      @$textarea.insertAtCaret(
        "[url=#{value}]",
        "[/url]",
        value.replace(/^https?:\/\/|\/.*/g, "")
      )

    # построение бб-кода для аниме,манги,персонажа и человека
    LINK_TYPES = [
      '.links #link_type_anime'
      '.links #link_type_manga'
      '.links #link_type_ranobe'
      '.links #link_type_character'
      '.links #link_type_person'
    ]
    @$(LINK_TYPES.join(',')).on 'tag:build', (e, data) =>
      @$textarea.insertAtCaret(
        "[#{data.type}=#{data.id}]", "[/#{data.type}]", data.text
      )
    # @$('.links #link_type_ranobe').on 'tag:build', (e, data) =>
      # @$textarea.insertAtCaret(
        # "[#{data.type}=#{data.id}]", "[/#{data.type}]", data.text
      # )

    # открытие блока со смайлами
    @$('.smileys').on 'click:open', (e) =>
      $block = $(e.target)
      # при показе можем подгрузить контент с сервера
      if $block.data('href')
        $block.load $block.data('href'), =>
          $block.data href: null
          # клик на картинку смайлика
          @$('.smileys img').on 'click', (e) =>
            bb_code = $(e.target).attr('alt')
            @$textarea.insertAtCaret '', bb_code
            @$('.editor-smiley').trigger('click')

          # после прогрузки всех смайлов зададим высоту, чтобы плавно открывалось
          #@$('.smileys img').imagesLoaded ->
            #block_height = $block.css('height')

    # нажатие на метку оффтопика
    @$('.b-offtopic_marker').on 'click', =>
      @_mark_offtopic @$('.b-offtopic_marker').hasClass('off')

    # нажатие на метку отзыва
    @$('.b-summary_marker').on 'click', =>
      @_mark_review @$('.b-summary_marker').hasClass('off')

    # назад к редактированию при предпросмотре
    @$('footer .unpreview').on 'click', @_hide_preview

    # предпросмотр
    @$('footer .preview').on 'click', =>
      # подстановка данных о текущем элементе, если они есть
      data = {}
      item_data = if @is_inner_form
        @$form.serializeHash()[@_type()]
      else
        @$root.triggerWithReturn('preview:params') || {
          body: @$textarea.val()
        }
      data[@_type()] = item_data

      @_shade()
      axios
        .post(
          $('footer .preview', @$root).data('preview_url'),
          data
        )
        .then (response) => @_show_preview(response.data)
        .catch()
        .then(@_unshade)

    # отзыв и оффтопик
    #@$('.item-offtopic, .item-summary').click (e, data) =>
      #$button = $(e.target)
      #kind = if $button.hasClass('item-offtopic') then 'offtopic' else 'summary'
      #$button.toggleClass('selected')
      #new_value = if $button.hasClass('selected') then '1' else '0'
      #@$("#comment_#{kind}").val(new_value)

    # редактирование
    # сохранение при редактировании коммента
    @$('.item-apply').on 'click', (e, data) =>
      @$form.submit()

    # фокус на редакторе
    if @$textarea.val().length > 0
      # delay надо, т.к. IE не может делать focus и
      # работать с Range (внутри setCursorPosition) для невидимых элементов
      delay().then =>
        @$textarea.focus()
        @$textarea.setCursorPosition @$textarea.val().length

    if $.browser.opera && parseInt($.browser.version) < 12
      @$('.editor-file').hide()

    # ajax загрузка файлов
    file_text_placeholder = "[#{I18n.t('frontend.shiki_editor.file')} #@]"
    @$textarea.shikiFile
      progress: $root.find('.b-upload_progress')
      input: $('.editor-file input', $root)
      maxfiles: 6

    .on 'upload:started', (e, file_num) =>
      file_text = file_text_placeholder.replace('@', file_num)
      @$textarea.insertAtCaret "", file_text
      @$textarea.focus()

    .on 'upload:before upload:after', (e, file_num) =>
      @$('.editor-upload').trigger('click')

    .on 'upload:success', (e, data, file_num) =>
      file_text = file_text_placeholder.replace('@', file_num)
      if @$textarea.val().indexOf(file_text) == -1
        @$textarea.insertAtCaret '', "[image=#{data.id}]"
      else
        text = if data.id then "[image=#{data.id}]" else ''
        @$textarea.val @$textarea.val().replace file_text, text
      @$textarea.focus()

    .on 'upload:failed', (e, response, file_num) =>
      file_text = file_text_placeholder.replace('@', file_num)

      unless @$textarea.val().indexOf(file_text) is -1
        @$textarea.val @$textarea.val().replace(file_text, '')

      @$textarea.focus()

  _show_preview: (preview_html) ->
    @$root.addClass('previewed')
    $('.body .preview', @$root)
      .html(preview_html)
      .process()
      .shikiEditor()

  _hide_preview: =>
    @$root.removeClass('previewed')
    $.scrollTo @$root unless @$('.editor-controls').is(':appeared')

  _mark_offtopic: (is_offtopic) ->
    @$('#comment_is_offtopic').val if is_offtopic then 'true' else 'false'
    @$('.b-offtopic_marker').toggleClass 'off', !is_offtopic

  _mark_review: (is_review) ->
    @$('#comment_is_summary').val if is_review then 'true' else 'false'
    @$('.b-summary_marker').toggleClass 'off', !is_review

  # очистка редактора
  cleanup: ->
    @_mark_offtopic false
    @_mark_review false
    @$textarea
      .val('')
      .trigger('update')

  # ответ на комментарий
  reply_comment: (text, is_offtopic) ->
    @_mark_offtopic true if is_offtopic

    @$textarea
      .val("#{@$textarea.val()}\n#{text}".replace(/^\n+/, ''))
      .focus()
      .trigger('update') # для elastic плагина
      .setCursorPosition(@$textarea.val().length)

    setTimeout =>
      if (isMobile() || isTablet()) && !@$textarea.is(':appeared')
        $.scrollTo @$form, null, =>
          @$textarea.focus()

  # переход в режим редактирования комментария
  edit_comment: ($comment) ->
    $initial_content = $comment.children().detach()
    $comment.append(@$root)

    # отмена редактирования
    @$('.cancel').on 'click', =>
      @$root.remove()
      $comment.append($initial_content)

    # замена комментария после успешного сохранения
    @on 'ajax:success', (e, response) ->
      $comment.view()._replace response.html, response.JS_EXPORTS

  _type: ->
    @$textarea.data('item_type')
