(($) ->
  $.fn.extend
    shiki_editor: ->
      @each ->
        $root = $(@)
        return unless $root.hasClass('unprocessed')

        new ShikiEditor($root)
) jQuery

# TODO: в кнструктор перенесён весь старый код. надо отрефакторить.
# подумать над view бекбона # (если на ShikiComment будет переведён на бекбон)
class @ShikiEditor extends ShikiView
  initialize: ($root) ->
    @$form = @$('form')
    @$textarea = @$('textarea')

    # при вызове фокуса на shiki-editor передача сообщения в редактор
    @on 'focus', => @$textarea.trigger('focus')

    # по первому фокусу на редактор включаем elastic
    @$textarea.one 'focus', =>
      @$textarea.elastic.bind(@$textarea).delay()

    # сохранение по ctrl+enter
    @$textarea.on 'keypress keydown', (e) =>
      if e.metaKey || e.ctrlKey
        if e.keyCode is 10 || e.keyCode is 13
          @$form.submit()
          false

        else if e.keyCode is 98 || e.keyCode is 66
          # b tag
          @$('.editor-bold').click()
          false

        else if e.keyCode is 105 || e.keyCode is 73
          # i tag
          @$('.editor-italic').click()
          false

        # spoiler tag
        else if e.keyCode is 115 || e.keyCode is 83
          @$('.editor-spoiler').click()
          false

    # перед самбитом формы засветление редактора
    @$form.on 'ajax:before', =>
      @$root.addClass 'ajax_request'
    # восстановление засветлённости после сабмита
    @$form.on 'ajax:complete', =>
      @$root.removeClass 'ajax_request'

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
      @$textarea.insertAtCaret '[spoiler=спойлер]', '[/spoiler]'

    # смайлики и ссылка
    ['smiley', 'link', 'image', 'quote', 'upload'].each (key) =>
      @$(".editor-#{key}").on 'click', (e) =>
        $button = $(e.target)
        $block = @$(".#{key}s")

        if $button.hasClass('selected')
          $block.animated_collapse()
        else
          $block.animated_expand()
          $block.trigger('click:open')

        $button.toggleClass('selected')

    # открытие блока ссылки
    @$('.links').on 'click:open', =>
      @$('.links input[type=text]').val('')
      @$('#link_type_url')
        .attr(checked: true)
        .trigger('change')

    # автокомплит для поля ввода ссылки
    @$(".links input[type=text]")
      .completable()
      .on 'autocomplete:success autocomplete:text',  (e, result) =>
        $radio = @$(".links input[type=radio]:checked")
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
    @$(".links input[type=radio]").on 'change', ->
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
    @$(".images input[type=text]").on 'keypress', (e) =>
      if e.keyCode is 13
        @$textarea.insertAtCaret '', "[img]#{@value}[/img]"
        @$(".editor-image").trigger('click')
        false

    # открытие блока цитаты
    @$(".quotes").on "click:open", =>
      # чистим текущий введённый текст
      @$(".quotes input[type=text]").val('').focus()

    # сабмит цитаты в текстовом поле
    @$(".quotes input[type=text]").on 'keypress', (e) =>
      if e.keyCode is 13
        @$textarea.insertAtCaret "[quote" + ((if not @value or @value.isBlank() then "" else "=" + @value)) + "]", "[/quote]"
        @$(".editor-quote").trigger('click')
        false

    # автокомплит для поля ввода цитаты
    @$(".quotes input[type=text]")
      .completable()
      .on 'autocomplete:success autocomplete:text', (e, result) =>
        text = if Object.isString(result) then result else result.value
        @$textarea.insertAtCaret "[quote" + ((if not text or text.isBlank() then "" else "=" + text)) + "]", "[/quote]"
        @$(".editor-quote").trigger('click')

    # построение бб-кода для url
    @$('.links #link_type_url').on 'tag:build', (e, value) =>
      @$textarea.insertAtCaret "[url=#{value}]", "[/url]", value.replace(/^http:\/\/|\/.*/g, "")

    # построение бб-кода для аниме,манги,персонажа и человека
    @$('.links #link_type_anime,.links #link_type_manga,.links #link_type_character,.links #link_type_person').on 'tag:build', (e, data) =>
      @$textarea.insertAtCaret "[#{data.type}=#{data.id}]", "[/#{data.type}]", data.text

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
    @$('.b-review_marker').on 'click', =>
      @_mark_review @$('.b-review_marker').hasClass('off')

    # назад к редактированию при предпросмотре
    @$('footer .unpreview').on 'click', @_hide_preview

    # предпросмотр
    @$('footer .preview').on 'click', =>
      # подстановка данных о текущем элементе, если они есть
      data = {}
      item_data = if @$form.exists()
        @$form.serializeHash()[@_type()]
      else
        @$root.trigger_with_return('preview:params') || {
          body: @$textarea.val()
        }
      data[@_type()] = item_data

      $.ajax
        type: 'POST'
        url: $('footer .preview', @$root).data('preview_url')
        data: data
        success: (html) =>
          @_show_preview html

        error: ->

    # отзыв и оффтопик
    #@$('.item-offtopic, .item-review').click (e, data) =>
      #$button = $(e.target)
      #kind = if $button.hasClass('item-offtopic') then 'offtopic' else 'review'
      #$button.toggleClass('selected')
      #new_value = if $button.hasClass('selected') then '1' else '0'
      #@$("#comment_#{kind}").val(new_value)

    # редактирование
    # сохранение при редактировании коммента
    @$('.item-apply').on 'click', (e, data) =>
      @$form.submit()

    # фокус на редакторе
    if @$textarea.val().length > 0
      @$textarea.focus().setCursorPosition @$textarea.val().length
    if $.browser.opera && parseInt($.browser.version) < 12
      @$('.editor-file').hide()

    # ajax загрузка файлов
    file_text_placeholder = '[файл #@]'
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
      unless @$textarea.val().indexOf(file_text) is -1
        @$textarea.val @$textarea.val().replace(file_text, "[image=#{data.id}]")
      else
        @$textarea.insertAtCaret '', "[image=#{data.id}]"
      @$textarea.focus()

    .on 'upload:failed', (e, response, file_num) =>
      file_text = file_text_placeholder.replace('@', file_num)
      @$textarea.val @$textarea.val().replace(file_text, '') unless @$textarea.val().indexOf(file_text) is -1
      @$textarea.focus()

  _show_preview: (preview_html) ->
    @$root.addClass('previewed')
    $('.body .preview', @$root)
      .html(preview_html)
      .process()
      .shiki_editor()

  _hide_preview: =>
    @$root.removeClass('previewed')

  _mark_offtopic: (is_offtopic) ->
    @$('#comment_offtopic').val if is_offtopic then 't' else 'f'
    @$('.b-offtopic_marker').toggleClass 'off', !is_offtopic

  _mark_review: (is_review) ->
    @$('#comment_review').val if is_review then 't' else 'f'
    @$('.b-review_marker').toggleClass 'off', !is_review

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
      $comment.data('shiki_object')._replace response.html

  _type: ->
    @$textarea.data('item_type')
