(($) ->
  $.fn.extend
    shikiEditor: ->
      @each (i) ->
        $root = $(this)
        return if $root.data("initialized")
        $root.data "initialized", true
        $editor = $root.find(".editor-area")
        $editor.elastic()

        # при вызове фокуса на shiki-editor передача сообщения в редактор
        $root.focus ->
          $editor.trigger "focus"

        # сохранение по ctrl+enter
        $editor.keypress((e) ->
          $root.find("form").submit() if (e.keyCode is 10 or e.keyCode is 13) and e.ctrlKey
        ).keydown (e) ->
          $root.find("form").submit() if e.keyCode is 13 and e.metaKey

        # при клике на неselected кнопку, закрываем все остальные selected кнопки
        $(".editor-controls span", $root).click ->
          $this = $(this)
          $(".editor-controls span.selected", $root).trigger "click"  unless $this.hasClass("selected")

        # бб коды
        $(".editor-bold", $root).click ->
          $editor.insertAtCaret "[b]", "[/b]"

        $(".editor-italic", $root).click ->
          $editor.insertAtCaret "[i]", "[/i]"

        $(".editor-underline", $root).click ->
          $editor.insertAtCaret "[u]", "[/u]"

        $(".editor-strike", $root).click ->
          $editor.insertAtCaret "[s]", "[/s]"

        $(".editor-spoiler", $root).click ->
          $editor.insertAtCaret "[spoiler=спойлер]", "[/spoiler]"

        # смайлики и ссылка
        _.each ["smiley", "link", "image", "quote", "upload"], (key) ->
          $block = $("." + key + "s", $root)
          block_height = $block.css("height")
          if key is "smiley"
            block_height = 0
          else
            $block.css height: "0px"
            $block.show()
          $(".editor-" + key, $root).click ->
            $.scrollTo $root if not $editor.is(":appeared") and not $root.find(".buttons").is(":appeared")
            $this = $(this)
            if $this.hasClass("selected")

              # скрытие блока
              $this.removeClass "selected"
              $block.removeClass "with-transition" if ($.browser.chrome or $.browser.opera) and $block.height() > 200
              if block_height
                $block.css height: "0px"
              else
                $block.hide()

            else
              # показ блока
              $this.addClass "selected"
              $block.addClass "with-transition" if $.browser.chrome or $.browser.opera
              if block_height
                $block.css height: block_height
              else
                $block.show()
              $block.trigger "click:open"

              # при показе можем подгрузить контент с сервера
              if $block.data("href")
                $block.load $block.data("href"), ->

                  # клик на картинку смайлика
                  $(".smileys img", $root).click ->
                    $editor.insertAtCaret "", $(this).attr("alt")
                    $(".editor-smiley", $root).trigger "click"

                  # после прогрузки всех смайлов зададим высоту, чтобы плавно открывалось
                  $(".smileys img", $root).imagesLoaded ->
                    block_height = $block.css("height")

                $block.data "href", null

        # открытие блока ссылки
        $(".links", $root).bind "click:open", ->
          $(".links input[type=text]", $root).attr "value", ""
          $("#link_type_url", $root).attr("checked", true).trigger "change"

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
        $(".links input[type=radio]", $root).change ->
          $this = $(this)
          $input = $(".links input[type=text]", $root)
          $input.attr "placeholder", $this.data("placeholder") # меняем плейсхолдер
          if $this.data("autocomplete")
            $input.data "autocomplete", $this.data("autocomplete") # устанавливаем урл для автокомплита
          else
            $input.data "autocomplete", null
          # чистим кеш автокомплита
          #.attr('value', '') // чистим текущий введённый текст
          $input.trigger("flushCache").focus()

        # общий обработчик для всех радио кнопок, закрывающий блок со ссылками
        $(".links input[type=radio]", $root).bind "tag:build", (e, id, text) ->
          $(".editor-link", $root).trigger "click"

        # открытие блока картинки
        $(".images", $root).bind "click:open", ->
          # чистим текущий введённый текст
          $(".images input[type=text]", $root).attr("value", "").focus()

        # сабмит картинки в текстовом поле
        $(".images input[type=text]", $root).keypress (e) ->
          if e.keyCode is 13
            $editor.insertAtCaret "", "[img]" + @value + "[/img]"
            $(".editor-image", $root).trigger "click"
            false

        # открытие блока цитаты
        $(".quotes", $root).bind "click:open", ->
          # чистим текущий введённый текст
          $(".quotes input[type=text]", $root).attr("value", "").focus()

        # сабмит цитаты в текстовом поле
        $(".quotes input[type=text]", $root).keypress (e) ->
          if e.keyCode is 13
            $editor.insertAtCaret "[quote" + ((if not @value or @value.isBlank() then "" else "=" + @value)) + "]", "[/quote]"
            $(".editor-quote", $root).trigger "click"
            false

        # автокомплит для поля ввода цитаты
        $(".quotes input[type=text]", $root).make_completable null, (e, id, text) ->
          $editor.insertAtCaret "[quote" + ((if not text or text.isBlank() then "" else "=" + text)) + "]", "[/quote]"
          $(".editor-quote", $root).trigger "click"

        # построение бб тега для url
        $(".links #link_type_url", $root).bind "tag:build", (e, value) ->
          $editor.insertAtCaret "[url=" + value + "]", "[/url]", value.replace(/^http:\/\/|\/.*/g, "")

        # построение бб тега для аниме,манги,персонажа и человека
        $(".links #link_type_anime,.links #link_type_manga,.links #link_type_character,.links #link_type_person", $root).bind "tag:build", (e, data) ->
          type = @getAttribute("id").replace("link_type_", "")
          $editor.insertAtCaret "[" + type + "=" + data.id + "]", "[/" + type + "]", data.text

        # сохранение комента
        $(".item-controls .item-save", $root).live "click", ->
          $root.find("form").submit()

        # сохранение при предпросмотре
        $(".preview-controls .item-save", $root).live "click", ->
          $(".preview-controls .item-unpreview", $root).trigger "click"
          $(".item-controls .item-save", $root).trigger "click"

        # назад к редактированию при предпросмотре
        $(".preview-controls .item-unpreview", $root).click ->
          $root.removeClass "preview"
          $(".editor-controls", $root).show()
          $(".item-controls", $root).show()
          $(".preview-controls", $root).hide()
          $(".editor", $root).show()
          $(".body .preview", $root).hide()

        # предпросмотр
        $(".item-preview", $root).click ->
          $.cursorMessage()

          # подстановка данных о текущем элементе, если они есть
          $form = $(this).parents("form")
          if $form.length
            item_id = $form.find("#change_item_id").val()
            model = $form.find("#change_model").val()
            item_data = "&target_type=" + model + "&target_id=" + item_id if item_id and model
          $.ajax
            type: "POST"
            url: "/comments/preview"
            data: "body=" + encodeURIComponent($editor.attr("value")) + (item_data or "")
            success: (text) ->
              $.hideCursorMessage()
              $root.addClass "preview"
              $(".editor-controls", $root).hide()
              $(".item-controls", $root).hide()
              $(".preview-controls", $root).show()
              $(".editor", $root).hide()
              $(".body .preview", $root).html(text).show()
              process_current_dom()

            error: ->
              $.hideCursorMessage()

        # отзыв и оффтопик
        $(".item-offtopic, .item-review", $root).click (e, data) ->
          $this = $(this)
          kind = (if $this.hasClass("item-offtopic") then "offtopic" else "review")
          $this.toggleClass "selected"
          $root.find("#comment_" + kind).val (if $this.hasClass("selected") then "1" else "0")

        # редактирование
        # сохранение при редактировании коммента
        $(".item-apply", $root).click (e, data) ->
          $root.find("form").submit()

        # отмена при редактировании коммента
        $(".item-cancel", $root).bind "ajax:success", (e, data) ->
          $(this).parents(".comment-block").replaceWith data

        # фокус на редакторе
        $editor.focus().setCursorPosition $editor.attr("value").length if not $editor.hasClass("no-focus") and $editor.attr("value").length > 0
        $(".editor-file", $root).hide() if $.browser.opera and parseInt($.browser.version) < 12

        # ajax загрузка файлов
        file_text_placeholder = "[файл #@]"
        $editor.shikiFile(
          progress: $root.find(".upload-progress")
          input: $(".editor-file input", $root)
          maxfiles: 6
        ).on("upload:started", (e, file_num) ->
          file_text = file_text_placeholder.replace("@", file_num)
          $editor.insertAtCaret "", file_text
          $editor.focus()
        ).on("upload:before upload:after", (e, file_num) ->
          $(".editor-upload", $root).trigger "click"
        ).on("upload:success", (e, data, file_num) ->
          file_text = file_text_placeholder.replace("@", file_num)
          unless $editor.val().indexOf(file_text) is -1
            $editor.val $editor.val().replace(file_text, "[image=#{data.id}]")
          else
            $editor.insertAtCaret "", "[image=#{data.id}]"
          $editor.focus()
        ).on "upload:failed", (e, response, file_num) ->
          file_text = file_text_placeholder.replace("@", file_num)
          $editor.val $editor.val().replace(file_text, "")  unless $editor.val().indexOf(file_text) is -1
          $editor.focus()

    insertAtCaret: (prefix, postfix, filler) ->
      @each (i) ->
        if document.selection
          @focus()
          sel = document.selection.createRange()
          sel.text = prefix + ((if sel.text is "" and filler then filler else sel.text)) + postfix
          @focus()
        else if @selectionStart or @selectionStart is "0" or @selectionStart is 0
          startPos = @selectionStart
          endPos = @selectionEnd
          scrollTop = @scrollTop
          selectedText = @value.substring(startPos, endPos)
          selectedText = (if selectedText is "" and filler then filler else selectedText)
          @value = @value.substring(0, startPos) + prefix + selectedText + postfix + @value.substring(endPos, @value.length)
          @focus()
          @selectionEnd = @selectionStart = startPos + prefix.length + selectedText.length + postfix.length
          @scrollTop = scrollTop
        else
          @value += prefix + postfix
          @focus()

    setCursorPosition: (pos) ->
      el = $(this).get(0)
      return  unless el
      sel_done = false
      try
        if el.setSelectionRange
          el.setSelectionRange pos, pos
          sel_done = true
      if not sel_done and el.createTextRange
        range = el.createTextRange()
        range.collapse true
        range.moveEnd 'character', pos
        range.moveStart 'character', pos
        range.select()

) jQuery
