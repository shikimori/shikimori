(function($){

$.fn.extend({
  shikiEditor: function() {
    return this.each(function(i) {
      var $root = $(this);
      if ($root.data('initialized')) {
        return;
      }
      $root.data('initialized', true);

      var $editor = $root.find('.editor-area');
      $editor.elastic();

      // при вызове фокуса на shiki-editor передача сообщения в редактор
      $root.focus(function() {
        $editor.trigger('focus');
      });

      // сохранение по ctrl+enter
      $editor.keypress(function(e) {
        if ((e.keyCode == 10 || e.keyCode == 13) && e.ctrlKey) {
          $root.find('form').submit();
        }
      }).keydown(function(e) {
        if (e.keyCode == 13 && e.metaKey) {
          $root.find('form').submit();
        }
      });

      // при клике на неselected кнопку, закрываем все остальные selected кнопки
      $('.editor-controls span', $root).click(function() {
        var $this = $(this);
        if (!$this.hasClass('selected')) {
          $('.editor-controls span.selected', $root).trigger('click');
        }
      });

      // бб коды
      $('.editor-bold', $root).click(function() {
        $editor.insertAtCaret('[b]', '[/b]');
      });
      $('.editor-italic', $root).click(function() {
        $editor.insertAtCaret('[i]', '[/i]');
      });
      $('.editor-underline', $root).click(function() {
        $editor.insertAtCaret('[u]', '[/u]');
      });
      $('.editor-strike', $root).click(function() {
        $editor.insertAtCaret('[s]', '[/s]');
      });
      $('.editor-spoiler', $root).click(function() {
        $editor.insertAtCaret('[spoiler=спойлер]', '[/spoiler]');
      });
      // смайлики и ссылка
      _.each(['smiley', 'link', 'image', 'quote', 'upload'], function(key) {
        var $block = $('.'+key+'s', $root);
        var block_height = $block.css('height');
        if (key == 'smiley') {
          block_height = 0;
        } else {
          $block.css({height: '0px'});
          $block.show();
        }
        $('.editor-'+key, $root).click(function() {
          if (!$editor.is(':appeared') && !$root.find('.buttons').is(':appeared')) {
            $.scrollTo($root);
          }
          var $this = $(this);

          if ($this.hasClass('selected')) {
            // скрытие блока
            $this.removeClass('selected');
            if (($.browser.chrome || $.browser.opera) && $block.height() > 200) {
              $block.removeClass('with-transition');
            }
            if (block_height) {
              $block.css({height: '0px'});
            } else {
              $block.hide()
            }
          } else {
            // показ блока
            $this.addClass('selected');
            if ($.browser.chrome || $.browser.opera) {
              $block.addClass('with-transition');
            }
            if (block_height) {
              $block.css({height: block_height});
            } else {
              $block.show()
            }
            $block.trigger('click:open');

            // при показе можем подгрузить контент с сервера
            if ($block.data('href')) {
              $block.load($block.data('href'), function() {
                // клик на картинку смайлика
                $('.smileys img', $root).click(function() {
                  $editor.insertAtCaret('', $(this).attr('alt'));
                  $('.editor-smiley', $root).trigger('click');
                });

                // после прогрузки всех смайлов зададим высоту, чтобы плавно открывалось
                $('.smileys img', $root).imagesLoaded(function() {
                  block_height = $block.css('height');
                });
              });
              $block.data('href', null);
            }
          }
        });
      });
      // открытие блока ссылки
      $('.links', $root).bind('click:open', function() {
        $('.links input[type=text]', $root).attr('value', '');
        $('#link_type_url', $root).attr('checked', true).trigger('change');
      });
      // автокомплит для поля ввода ссылки
      $('.links input[type=text]', $root).make_completable(null, function(e, id, text) {
        if ($('.links input[type=radio][value=url]', $root).prop('checked')) {
          text = $('.links input.link-value', $root).val()
        }
        if (text) {
          if (id) {
            param = {id: id, text: text};
          } else {
            param = text;
          }
          $('.links input[type=radio]:checked', $root).trigger('tag:build', param);
        }
        //if (id && text) {
          //$('.links input[type=radio]:checked', $root).trigger('tag:build', {id: id, text: text});
        //}
      });
      // изменение типа ссылки
      $('.links input[type=radio]', $root).change(function() {
        var $this = $(this);
        var $input = $('.links input[type=text]', $root);
        $input.attr('placeholder', $this.data('placeholder')); // меняем плейсхолдер
        if ($this.data('autocomplete')) {
          $input.data('autocomplete', $this.data('autocomplete')); // устанавливаем урл для автокомплита
        } else {
          $input.data('autocomplete', null);
        }
        $input.trigger('flushCache') // чистим кеш автокомплита
              //.attr('value', '') // чистим текущий введённый текст
              .focus();
      });
      // сабмит ссылки в текстовом поле
      //$('.links input[type=text]', $root).keypress(function(e) {
        //if (e.keyCode == 13) {
          //$('.links input[type=radio]:checked', $root).trigger('tag:build', this.value);
          //return false;
        //}
      //});
      // общий обработчик для всех радио кнопок, закрывающий блок со ссылками
      $('.links input[type=radio]', $root).bind('tag:build', function(e, id, text) {
        $('.editor-link', $root).trigger('click');
      });
      // открытие блока картинки
      $('.images', $root).bind('click:open', function() {
        $('.images input[type=text]', $root).attr('value', '') // чистим текущий введённый текст
                                            .focus();
      });
      // сабмит картинки в текстовом поле
      $('.images input[type=text]', $root).keypress(function(e) {
        if (e.keyCode == 13) {
          $editor.insertAtCaret('', '[img]'+this.value+'[/img]');
          $('.editor-image', $root).trigger('click');
          return false;
        }
      });
      // открытие блока цитаты
      $('.quotes', $root).bind('click:open', function() {
        $('.quotes input[type=text]', $root).attr('value', '') // чистим текущий введённый текст
                                            .focus();
      });
      // сабмит цитаты в текстовом поле
      $('.quotes input[type=text]', $root).keypress(function(e) {
        if (e.keyCode == 13) {
          $editor.insertAtCaret('[quote'+(!this.value || this.value.isBlank() ? '' : '='+this.value)+']', '[/quote]');
          $('.editor-quote', $root).trigger('click');
          return false;
        }
      });
      // автокомплит для поля ввода цитаты
      $('.quotes input[type=text]', $root).make_completable(null, function(e, id, text) {
        $editor.insertAtCaret('[quote='+(!text || text.isBlank() ? '' : '='+text)+']', '[/quote]');
        $('.editor-quote', $root).trigger('click');
      });
      // построение бб тега для url
      $('.links #link_type_url', $root).bind('tag:build', function(e, value) {
        $editor.insertAtCaret('[url='+value+']', '[/url]', value.replace(/^http:\/\/|\/.*/g, ''));
      });
      // построение бб тега для аниме,манги,персонажа и человека
      $('.links #link_type_anime,.links #link_type_manga,.links #link_type_character,.links #link_type_person', $root).bind('tag:build', function(e, data) {
        var type = this.getAttribute('id').replace('link_type_', '');
        $editor.insertAtCaret('['+type+'='+data.id+']', '[/'+type+']', data.text);
      });

      // сохранение комента
      $('.item-controls .item-save', $root).live('click', function() {
        $root.find('form').submit();
      });
      // сохранение при предпросмотре
      $('.preview-controls .item-save', $root).live('click', function() {
        $('.preview-controls .item-unpreview', $root).trigger('click');
        $('.item-controls .item-save', $root).trigger('click');
      });
      // назад к редактированию при предпросмотре
      $('.preview-controls .item-unpreview', $root).click(function() {
        $root.removeClass('preview');
        $('.editor-controls', $root).show();
        $('.item-controls', $root).show();
        $('.preview-controls', $root).hide();
        $('.editor', $root).show();
        $('.body .preview', $root).hide();
      });
      // предпросмотр
      $('.item-preview', $root).click(function() {
        $.cursorMessage();

        // подстановка данных о текущем элементе, если они есть
        var $form = $(this).parents('form');
        if ($form.length) {
          var item_id = $form.find('#change_item_id').val();
          var model = $form.find('#change_model').val();
          if (item_id && model) {
            var item_data = '&target_type='+model+'&target_id='+item_id;
          }
        }

        $.ajax({
          type: 'POST',
          url: '/comments/preview',
          data: 'body=' + encodeURIComponent($editor.attr('value')) + (item_data || ''),
          success: function(text) {
            $.hideCursorMessage();
            $root.addClass('preview');
            $('.editor-controls', $root).hide();
            $('.item-controls', $root).hide();
            $('.preview-controls', $root).show();
            $('.editor', $root).hide();
            $('.body .preview', $root).html(text).show();
            process_current_dom();
          },
          error: function() {
            $.hideCursorMessage();
          }
        });
      });

      // отзыв и оффтопик
      $('.item-offtopic, .item-review', $root).click(function(e, data) {
        var $this = $(this);
        var kind = $this.hasClass('item-offtopic') ? 'offtopic' : 'review';
        $this.toggleClass('selected')
        $root.find('#comment_'+kind).val($this.hasClass('selected') ?  '1' : '0');
      });

      // редактирование
      // сохранение при редактировании коммента
      $('.item-apply', $root).click(function(e, data) {
        $root.find('form').submit();
      });
      // отмена при редактировании коммента
      $('.item-cancel', $root).bind('ajax:success', function(e, data) {
        $(this).parents('.comment-block').replaceWith(data);
      });

      // фокус на редакторе
      if (!$editor.hasClass('no-focus') && $editor.attr('value').length > 0) {
        $editor.focus().setCursorPosition($editor.attr('value').length);
      }


      if ($.browser.opera && parseInt($.browser.version) < 12) {
        $('.editor-file', $root).hide();
      }

      // ajax загрузка файлов
      var file_text_placeholder = '[файл #@]';
      $editor.shikiFile({
        progress: $root.find('.upload-progress'),
        input: $('.editor-file input', $root),
        maxfiles: 6
      })
      .on('upload:started', function(e, file_num) {
        var file_text = file_text_placeholder.replace('@', file_num);

        $editor.insertAtCaret('', file_text);
        $editor.focus();
      })
      .on('upload:before upload:after', function(e, file_num) {
        $('.editor-upload', $root).trigger('click');
      })
      .on('upload:success', function(e, response, file_num) {
        var file_text = file_text_placeholder.replace('@', file_num);

        if ($editor.val().indexOf(file_text) != -1) {
          $editor.val($editor.val().replace(file_text, response.bb_code));
        } else {
          $editor.insertAtCaret('', response.bb_code);
        }
        $editor.focus();
      })
      .on('upload:failed', function(e, response, file_num) {
        var file_text = file_text_placeholder.replace('@', file_num);

        if ($editor.val().indexOf(file_text) != -1) {
          $editor.val($editor.val().replace(file_text, ''));
        }
        $editor.focus();
      });
    });
  },
  insertAtCaret: function(prefix, postfix, filler) {
    return this.each(function(i) {
      if (document.selection) {
        this.focus();
        sel = document.selection.createRange();
        sel.text = prefix + (sel.text === '' && filler ? filler : sel.text) + postfix;
        this.focus();
      }
      else if (this.selectionStart || this.selectionStart == '0') {
        var startPos = this.selectionStart;
        var endPos = this.selectionEnd;
        var scrollTop = this.scrollTop;
        var selectedText = this.value.substring(startPos, endPos);
        selectedText = selectedText === '' && filler ? filler : selectedText;
        this.value = this.value.substring(0, startPos) +
                      prefix +
                      selectedText +
                      postfix +
                      this.value.substring(endPos, this.value.length);
        this.focus();
        this.selectionEnd = this.selectionStart = startPos + prefix.length + selectedText.length + postfix.length;
        this.scrollTop = scrollTop;
      } else {
        this.value += prefix + postfix;
        this.focus();
      }
    });
  },
  setCursorPosition: function(pos) {
    var el = $(this).get(0);
    if (!el) {
      return;
    }
    var sel_done = false;
    try {
      if (el.setSelectionRange) {
        el.setSelectionRange(pos, pos);
        sel_done = true;
      }
    } catch(e) {}
    if (!sel_done && el.createTextRange) {
      var range = el.createTextRange();
      range.collapse(true);
      range.moveEnd('character', pos);
      range.moveStart('character', pos);
      range.select();
    }
  }
});

})(jQuery);
