(($) ->
  $.fn.extend
    shiki_editor: ->
      @each ->
        $root = $(@)
        return unless $root.hasClass('unprocessed')

        new ShikiEditor($root)
) jQuery

# TODO: в кнструктор перенесён весь старый код. надо отрефакторить
class @ShikiEditor
  constructor: ($root) ->
    @$root = $root
    @$root.removeClass('unprocessed')
    $editor = @$root.find('.editor-area')

    # при вызове фокуса на shiki-editor передача сообщения в редактор
    @$root.on 'focus', ->
      $editor.trigger('focus')

    # по первому фокусу на редактор включаем elastic
    $editor.one 'focus', ->
      $editor.elastic()

    # сохранение по ctrl+enter
    $editor.on 'keypress', (e) ->
      $root.find('form').submit() if (e.keyCode is 10 or e.keyCode is 13) and e.ctrlKey
    .on 'keydown', (e) ->
      $root.find('form').submit() if e.keyCode is 13 and e.metaKey

    # при клике на неselected кнопку, закрываем все остальные selected кнопки
    $('.editor-controls span', @$root).on 'click', ->
      unless $(@).hasClass('selected')
        $('.editor-controls span.selected', $root).trigger('click')

    # бб коды
    $('.editor-bold', @$root).on 'click', ->
      $editor.insertAtCaret '[b]', '[/b]'

    $('.editor-italic', @$root).on 'click', ->
      $editor.insertAtCaret '[i]', '[/i]'

    $('.editor-underline', @$root).on 'click', ->
      $editor.insertAtCaret '[u]', '[/u]'

    $('.editor-strike', @$root).on 'click', ->
      $editor.insertAtCaret '[s]', '[/s]'

    $('.editor-spoiler', @$root).on 'click', ->
      $editor.insertAtCaret '[spoiler=спойлер]', '[/spoiler]'

    # смайлики и ссылка
    _.each ['smiley', 'link', 'image', 'quote', 'upload'], (key) ->
      $block = $(".#{key}s", $root)
      block_height = $block.css('height')
      if key is "smiley"
        block_height = 0
      else
        $block.css height: '0px'
        $block.show()

      $(".editor-#{key}", $root).on 'click', ->
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
    $('.links', $root).on 'click:open', ->
      $('.links input[type=text]', $root).val('')
      $('#link_type_url', $root).attr(checked: true).trigger "change"

    # автокомплит для поля ввода ссылки
    $(".links input[type=text]", $root).make_completable null, (e, id, text) ->
      text = $(".links input.link-value", $root).val() if $(".links input[type=radio][value=url]", $root).prop("checked")
      if text
        if id
          param =
            id: id
            text: text
        else
          param = text
        $(".links input[type=radio]:checked", $root).trigger "tag:build", param

    # изменение типа ссылки
    $(".links input[type=radio]", $root).on 'change', ->
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
    $('.links input[type=radio]', $root).on 'tag:build', (e, id, text) ->
      $('.editor-link', $root).trigger('click')

    # открытие блока картинки
    $('.images', $root).on 'click:open', ->
      # чистим текущий введённый текст
      $('.images input[type=text]', $root).val('').focus()

    # сабмит картинки в текстовом поле
    $(".images input[type=text]", $root).on 'keypress', (e) ->
      if e.keyCode is 13
        $editor.insertAtCaret '', "[img]#{@value}[/img]"
        $(".editor-image", $root).trigger('click')
        false

    # открытие блока цитаты
    $(".quotes", $root).on "click:open", ->
      # чистим текущий введённый текст
      $(".quotes input[type=text]", $root).val('').focus()

    # сабмит цитаты в текстовом поле
    $(".quotes input[type=text]", $root).on 'keypress', (e) ->
      if e.keyCode is 13
        $editor.insertAtCaret "[quote" + ((if not @value or @value.isBlank() then "" else "=" + @value)) + "]", "[/quote]"
        $(".editor-quote", $root).trigger 'click'
        false

    # автокомплит для поля ввода цитаты
    $(".quotes input[type=text]", $root).make_completable null, (e, id, text) ->
      $editor.insertAtCaret "[quote" + ((if not text or text.isBlank() then "" else "=" + text)) + "]", "[/quote]"
      $(".editor-quote", $root).trigger 'click'

    # построение бб тега для url
    $('.links #link_type_url', $root).on 'tag:build', (e, value) ->
      $editor.insertAtCaret "[url=#{value}]", "[/url]", value.replace(/^http:\/\/|\/.*/g, "")

    # построение бб тега для аниме,манги,персонажа и человека
    $('.links #link_type_anime,.links #link_type_manga,.links #link_type_character,.links #link_type_person', $root).on 'tag:build', (e, data) ->
      type = @getAttribute('id').replace('link_type_', '')
      $editor.insertAtCaret "[#{type}=#{data.id}]", "[/#{type}]", data.text

    # сохранение комента
    #$root.on 'click', '.item-controls .item-save', ->
      #$root.find('form').submit()

    # сохранение при предпросмотре
    #$root.on 'click', '.preview-controls .item-save', ->
      #$('.preview-controls .item-unpreview', $root).trigger 'click'
      #$('.item-controls .item-save', $root).trigger 'click'

    # назад к редактированию при предпросмотре
    $root.on 'click', '.preview-controls .item-unpreview', ->
      $root.removeClass 'preview'
      $('.editor-controls', $root).show()
      $('.item-controls', $root).show()
      $('.preview-controls', $root).hide()
      $('.editor', $root).show()
      $('.body .preview', $root).hide()

    # предпросмотр
    $(".preview", $root).on 'click', ->
      $.cursorMessage()

      # подстановка данных о текущем элементе, если они есть
      $form = $(@).closest('form')
      if $form.length
        item_id = $form.find('#change_item_id').val()
        model = $form.find('#change_model').val()
        item_data = "&target_type=#{model}&target_id=#{item_id if item_id && model}"

      $.ajax
        type: 'POST'
        url: '/comments/preview'
        data: 'body=' + encodeURIComponent($editor.val()) + (item_data || "")
        success: (text) ->
          $.hideCursorMessage()
          $root.addClass('preview')
          $('.editor-controls', $root).hide()
          $('.item-controls', $root).hide()
          $('.preview-controls', $root).show()
          $('.editor', $root).hide()
          $('.body .preview', $root).html(text).show()
          process_current_dom()

        error: ->
          $.hideCursorMessage()

    # отзыв и оффтопик
    $('.item-offtopic, .item-review', $root).click (e, data) ->
      $this = $(@)
      kind = (if $(@).hasClass('item-offtopic') then 'offtopic' else 'review')
      $(@).toggleClass('selected')
      $root.find("#comment_#{kind}").val (if $(@).hasClass('selected') then '1' else '0')

    # редактирование
    # сохранение при редактировании коммента
    $('.item-apply', $root).on 'click', (e, data) ->
      $root.find('form').submit()

    # фокус на редакторе
    $editor.focus().setCursorPosition $editor.val().length if $editor.val().length > 0
    $('.editor-file', $root).hide() if $.browser.opera and parseInt($.browser.version) < 12

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

  # переход в режим редактирования комментария
  edit_comment: ($comment) ->
    $initial_content = $comment.children().detach()
    $comment.append(@$root)

    # отмена редактирования
    $('.cancel', @$root).on 'click', =>
      @$root.remove()
      $comment
        .append($initial_content)
        .yellowFade()
