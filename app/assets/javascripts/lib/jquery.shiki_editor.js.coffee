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
    $editor = @$('.editor-area')
    @$form = @$('form')
    @$textarea = @$('textarea')

    # при вызове фокуса на shiki-editor передача сообщения в редактор
    @on 'focus', -> $editor.trigger('focus')

    # по первому фокусу на редактор включаем elastic
    $editor.one 'focus', ->
      $editor.elastic()

    # сохранение по ctrl+enter
    $editor.on 'keypress', (e) ->
      $root.find('form').submit() if (e.keyCode is 10 or e.keyCode is 13) and e.ctrlKey
    .on 'keydown', (e) ->
      $root.find('form').submit() if e.keyCode is 13 and e.metaKey

    # при клике на неselected кнопку, закрываем все остальные selected кнопки
    @$('.editor-controls span').on 'click', ->
      unless $(@).hasClass('selected')
        $('.editor-controls span.selected', $root).trigger('click')

    # бб коды
    @$('.editor-bold').on 'click', ->
      $editor.insertAtCaret '[b]', '[/b]'

    @$('.editor-italic').on 'click', ->
      $editor.insertAtCaret '[i]', '[/i]'

    @$('.editor-underline').on 'click', ->
      $editor.insertAtCaret '[u]', '[/u]'

    @$('.editor-strike').on 'click', ->
      $editor.insertAtCaret '[s]', '[/s]'

    @$('.editor-spoiler').on 'click', ->
      $editor.insertAtCaret '[spoiler=спойлер]', '[/spoiler]'

    # смайлики и ссылка
    _.each ['smiley', 'link', 'image', 'quote', 'upload'], (key) =>
      $block = @$(".#{key}s")

      block_height = $block.css('height')
      if key is "smiley"
        block_height = 0
      else
        $block.css height: '0px'
        $block.show()

      @$(".editor-#{key}").on 'click', ->
        $.scrollTo $root if not $editor.is(':appeared') and not $root.find(".buttons").is(":appeared")
        $this = $(@)
        if $this.hasClass('selected')

          # скрытие блока
          $this.removeClass 'selected'
          $block.removeClass 'with-transition' if ($.browser.chrome or $.browser.opera) and $block.height() > 200
          if block_height
            $block.css height: '0px'
          else
            $block.hide()

        else
          # показ блока
          $this.addClass 'selected'
          $block.addClass 'with-transition' if $.browser.chrome or $.browser.opera
          if block_height
            $block.css height: block_height
          else
            $block.show()
          $block.trigger 'click:open'

          # при показе можем подгрузить контент с сервера
          if $block.data('href')
            $block.load $block.data('href'), ->

              # клик на картинку смайлика
              $('.smileys img', $root).click ->
                $editor.insertAtCaret '', $(@).attr('alt')
                $('.editor-smiley', $root).trigger('click')

              # после прогрузки всех смайлов зададим высоту, чтобы плавно открывалось
              $('.smileys img', $root).imagesLoaded ->
                block_height = $block.css('height')

            $block.data href: null

    # открытие блока ссылки
    @$('.links').on 'click:open', =>
      @$('.links input[type=text]').val('')
      @$('#link_type_url')
        .attr(checked: true)
        .trigger('change')

    # автокомплит для поля ввода ссылки
    @$(".links input[type=text]").make_completable null, (e, id, text) =>
      if @$(".links input[type=radio][value=url]").prop("checked")
        text = @$(".links input.link-value").val()

      if text
        if id
          param =
            id: id
            text: text
        else
          param = text
        @$(".links input[type=radio]:checked").trigger("tag:build", param)

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
    @$('.links input[type=radio]').on 'tag:build', (e, id, text) =>
      @$('.editor-link').trigger('click')

    # открытие блока картинки
    @$('.images').on 'click:open', =>
      # чистим текущий введённый текст
      @$('.images input[type=text]').val('').focus()

    # сабмит картинки в текстовом поле
    @$(".images input[type=text]").on 'keypress', (e) =>
      if e.keyCode is 13
        $editor.insertAtCaret '', "[img]#{@value}[/img]"
        @$(".editor-image").trigger('click')
        false

    # открытие блока цитаты
    @$(".quotes").on "click:open", =>
      # чистим текущий введённый текст
      @$(".quotes input[type=text]").val('').focus()

    # сабмит цитаты в текстовом поле
    @$(".quotes input[type=text]").on 'keypress', (e) =>
      if e.keyCode is 13
        $editor.insertAtCaret "[quote" + ((if not @value or @value.isBlank() then "" else "=" + @value)) + "]", "[/quote]"
        @$(".editor-quote").trigger('click')
        false

    # автокомплит для поля ввода цитаты
    @$(".quotes input[type=text]").make_completable null, (e, id, text) =>
      $editor.insertAtCaret "[quote" + ((if not text or text.isBlank() then "" else "=" + text)) + "]", "[/quote]"
      @$(".editor-quote").trigger('click')

    # построение бб тега для url
    @$('.links #link_type_url').on 'tag:build', (e, value) ->
      $editor.insertAtCaret "[url=#{value}]", "[/url]", value.replace(/^http:\/\/|\/.*/g, "")

    # построение бб тега для аниме,манги,персонажа и человека
    @$('.links #link_type_anime,.links #link_type_manga,.links #link_type_character,.links #link_type_person').on 'tag:build', (e, data) ->
      type = @getAttribute('id').replace('link_type_', '')
      $editor.insertAtCaret "[#{type}=#{data.id}]", "[/#{type}]", data.text

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
      $.cursorMessage()

      # подстановка данных о текущем элементе, если они есть
      #$form = $root.find('form')
      #item_data = if $form.length
        ##item_id = $form.find('#change_item_id').val()
        ##model = $form.find('#change_model').val()

        ##item_id = $form.find('#comment_commentable_type').val()
        ##model = $form.find('#comment_commentable_id').val()
        ##"&target_type=#{model}&target_id=#{item_id if item_id && model}"
        #''

      #else
        #''

      $.ajax
        type: 'POST'
        url: $('footer .preview', @$root).data('preview_url')
        data:
          comment: @$form.serializeHash().comment
        success: (html) =>
          $.hideCursorMessage()
          @_show_preview html

        error: ->
          $.hideCursorMessage()

    # отзыв и оффтопик
    @$('.item-offtopic, .item-review').click (e, data) ->
      kind = if $(@).hasClass('item-offtopic') then 'offtopic' else 'review'
      $(@).toggleClass('selected')
      new_value = if $(@).hasClass('selected') then '1' else '0'
      $root.find("#comment_#{kind}").val(new_value)

    # редактирование
    # сохранение при редактировании коммента
    @$('.item-apply').on 'click', (e, data) =>
      @$form.submit()

    # фокус на редакторе
    if $editor.val().length > 0
      $editor.focus().setCursorPosition $editor.val().length
    if $.browser.opera && parseInt($.browser.version) < 12
      @$('.editor-file').hide()

    # ajax загрузка файлов
    file_text_placeholder = '[файл #@]'
    $editor.shikiFile
      progress: $root.find('.upload-progress')
      input: $('.editor-file input', $root)
      maxfiles: 6

    .on 'upload:started', (e, file_num) ->
      file_text = file_text_placeholder.replace('@', file_num)
      $editor.insertAtCaret "", file_text
      $editor.focus()

    .on 'upload:before upload:after', (e, file_num) ->
      $('.editor-upload', $root).trigger('click')

    .on 'upload:success', (e, data, file_num) ->
      file_text = file_text_placeholder.replace('@', file_num)
      unless $editor.val().indexOf(file_text) is -1
        $editor.val $editor.val().replace(file_text, "[image=#{data.id}]")
      else
        $editor.insertAtCaret '', "[image=#{data.id}]"
      $editor.focus()

    .on 'upload:failed', (e, response, file_num) ->
      file_text = file_text_placeholder.replace('@', file_num)
      $editor.val $editor.val().replace(file_text, '') unless $editor.val().indexOf(file_text) is -1
      $editor.focus()

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
    @$textarea.val ''

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
      $comment.trigger 'comment:replace', response.html
