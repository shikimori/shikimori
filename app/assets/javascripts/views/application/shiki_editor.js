import delay from 'delay';
import autosize from 'autosize';
import { bind } from 'decko';

import axios from 'helpers/axios';
import ShikiView from 'views/application/shiki_view';

import { isMobile } from 'helpers/mobile_detect';
import flash from 'services/flash';

// TODO: refactor constructor
export default class ShikiEditor extends ShikiView {
  initialize() {
    const { $root } = this;
    this.$form = this.$('form');

    if (this.$form.exists()) {
      this.is_inner_form = true;
    } else {
      this.$form = $root.closest('form');
      this.is_inner_form = false;
    }

    this.$textarea = this.$('textarea');

    // при вызове фокуса на shiki-editor передача сообщения в редактор
    this.on('focus', () => this.$textarea.trigger('focus'));

    // по первому фокусу на редактор включаем autosize
    this.$textarea.one('focus', () => delay().then(() => autosize(this.$textarea[0])));

    this.$textarea.on('keypress keydown', e => {
      if (e.keyCode === 27) { // esc
        this.$textarea.blur();
        return false;
      } if (e.metaKey || e.ctrlKey) {
        // сохранение по ctrl+enter
        if ((e.keyCode === 10) || (e.keyCode === 13)) {
          this.$form.submit();
          return false;

        // [b] tag
        // else if e.keyCode == 98 || e.keyCode == 66
        } if (e.keyCode === 66) { // b
          this.$('.editor-bold').click();
          return false;

        // [i] tag
        // else if e.keyCode == 105 || e.keyCode == 73
        } if (e.keyCode === 73) { // i
          this.$('.editor-italic').click();
          return false;

        // [u] tag
        // else if e.keyCode == 117 || e.keyCode == 85
        } if (e.keyCode === 85) { // u
          this.$('.editor-underline').click();
          return false;

        // spoiler tag
        // else if e.keyCode == 115 || e.keyCode == 83
        } if (e.keyCode === 83) { // s
          this.$('.editor-spoiler').click();
          return false;

        // code tag
        } if (e.keyCode === 79) { // o
          this.$textarea.insertAtCaret('[code]', '[/code]');
          return false;
        }
      }
    });

    this.$form
      .on('ajax:before', () => {
        if (this.$textarea.val().replace(/\n| |\r|\t/g, '')) {
          return this._shade();
        }
        flash.error(I18n.t('frontend.shiki_editor.text_cant_be_blank'));
        return false;
      }).on('ajax:complete', this._unshade)
      .on('ajax:success', () => {
        this._hidePreview();
        return delay().then(() => this.$textarea[0].dispatchEvent(new Event('autosize:update')));
      });

    // при клике на неselected кнопку, закрываем все остальные selected кнопки
    this.$('.editor-controls span').on('click', e => {
      if (!$(e.target).hasClass('selected')) {
        this.$('.editor-controls span.selected').trigger('click');
      }
    });

    // бб коды
    this.$('.editor-bold').on('click', () => this.$textarea.insertAtCaret('[b]', '[/b]'));

    this.$('.editor-italic').on('click', () => this.$textarea.insertAtCaret('[i]', '[/i]'));

    this.$('.editor-underline').on('click', () => this.$textarea.insertAtCaret('[u]', '[/u]'));

    this.$('.editor-strike').on('click', () => this.$textarea.insertAtCaret('[s]', '[/s]'));

    this.$('.editor-spoiler').on('click', () => this.$textarea.insertAtCaret(
      `[spoiler=${I18n.t('frontend.shiki_editor.spoiler')}]`, '[/spoiler]'
    ));

    // смайлики и ссылка
    ['smiley', 'link', 'image', 'quote', 'upload'].forEach(key => this.$(`.editor-${key}`).on('click', e => {
      const $button = $(e.target);
      const $block = this.$(`.${key}s`);

      if ($button.hasClass('selected')) {
        $block.addClass('hidden');
      } else {
        $block.removeClass('hidden');
        $block.trigger('click:open');
      }

      return $button.toggleClass('selected');
    }));

    // кнопка сабмита OK
    this.$('.b-button.ok').on('click', e => {
      const type = $(e.target).data('type');

      const $input = this.$(`.${type} input[type=text]`);
      if (type === 'images') {
        return $input.trigger('keypress', [true]);
      }
      return $input.trigger('autocomplete:text', [$input.val()]);
    });

    // открытие блока ссылки
    this.$('.links').on('click:open', () => {
      $('.links input[type=text]', $root).val('');

      return $(this.$('[name="link_type"]:checked')[0] || this.$('[name="link_type"]')[0])
        .prop('checked', true)
        .trigger('change');
    });

    // автокомплит для поля ввода ссылки
    this.$('.links input[type=text]')
      .completable()
      .on('autocomplete:success autocomplete:text', (e, result) => {
        const $radio = this.$('.links input[type=radio]:checked');
        const radioType = $radio.val();

        const param = (() => {
          if (Object.isString(result)) {
            if (radioType === 'url') {
              return result;
            }
          } else {
            return {
              id: result.id,
              text: result.name,
              type: radioType
            };
          }
        })();

        if (param) { return $radio.trigger('tag:build', param); }
      });

    // изменение типа ссылки
    this.$('.links input[type=radio]').on('change', function () {
      const $this = $(this);
      const $input = $('.links input[type=text]', $root);
      $input.attr({ placeholder: $this.data('placeholder') }); // меняем плейсхолдер

      if ($this.data('autocomplete')) {
        $input.data({ autocomplete: $this.data('autocomplete') }); // устанавливаем урл для автокомплита
      } else {
        $input.data({ autocomplete: null });
      }

      // чистим кеш автокомплита
      // .attr('value', '') // чистим текущий введённый текст
      return $input.trigger('flushCache').focus();
    });

    // общий обработчик для всех радио кнопок, закрывающий блок со ссылками
    this.$('.links input[type=radio]').on('tag:build', (e, data) => this.$('.editor-link').trigger('click'));

    // открытие блока картинки
    this.$('.images').on('click:open', () =>
      // чистим текущий введённый текст
      this.$('.images input[type=text]').val('').focus()
    );

    // сабмит картинки в текстовом поле
    this.$('.images input[type=text]').on('keypress', (e, isForceSubmit) => {
      if ((e.keyCode === 10) || (e.keyCode === 13) || isForceSubmit) {
        this.$textarea.insertAtCaret('', `[img]${$(e.target).val()}[/img]`);
        this.$('.editor-image').trigger('click');
        return false;
      }
    });

    // открытие блока цитаты
    this.$('.quotes').on('click:open', () =>
      // чистим текущий введённый текст
      this.$('.quotes input[type=text]').val('').focus()
    );

    // сабмит цитаты в текстовом поле
    this.$('.quotes input[type=text]').on('keypress', e => {
      if ((e.keyCode === 10) || (e.keyCode === 13)) {
        this.$textarea.insertAtCaret(
          '[quote' +
            ((!this.value || this.value.isBlank() ? '' : `=${this.value}`)) +
            ']',
          '[/quote]'
        );
        this.$('.editor-quote').trigger('click');
        return false;
      }
    });

    // автокомплит для поля ввода цитаты
    this.$('.quotes input[type=text]')
      .completable()
      .on('autocomplete:success autocomplete:text', (e, result) => {
        const text = Object.isString(result) ? result : result.value;
        this.$textarea.insertAtCaret(
          '[quote' +
            (!text || text.isBlank() ? '' : `=${text}`) + ']',
          '[/quote]'
        );
        return this.$('.editor-quote').trigger('click');
      });

    // построение бб-кода для url
    this.$('.links input[value=url]').on('tag:build', (e, value) => this.$textarea.insertAtCaret(
      `[url=${value}]`,
      '[/url]',
      value.replace(/^https?:\/\/|\/.*/g, '')
    ));

    // построение бб-кода для аниме,манги,персонажа и человека
    const LINK_TYPES = [
      '.links input[value=anime]',
      '.links input[value=manga]',
      '.links input[value=ranobe]',
      '.links input[value=character]',
      '.links input[value=person]'
    ];
    this.$(LINK_TYPES.join(',')).on('tag:build', (e, data) => this.$textarea.insertAtCaret(
      `[${data.type}=${data.id}]`, `[/${data.type}]`, data.text
    ));

    // открытие блока со смайлами
    this.$('.smileys').on('click:open', e => {
      const $block = $(e.target);
      // при показе можем подгрузить контент с сервера
      if ($block.data('href')) {
        return $block.load($block.data('href'), () => {
          $block.data({ href: null });
          // клик на картинку смайлика
          return this.$('.smileys img').on('click', e => {
            const bbCode = $(e.target).attr('alt');
            this.$textarea.insertAtCaret('', bbCode);
            return this.$('.editor-smiley').trigger('click');
          });
        });
      }
    });

          // после прогрузки всех смайлов зададим высоту, чтобы плавно открывалось
          // @$('.smileys img').imagesLoaded ->
            // block_height = $block.css('height')

    // нажатие на метку оффтопика
    this.$('.b-offtopic_marker').on('click', () => this._markOfftopic(this.$('.b-offtopic_marker').hasClass('off')));

    // нажатие на метку отзыва
    this.$('.b-summary_marker').on('click', () => this._markReview(this.$('.b-summary_marker').hasClass('off')));

    // назад к редактированию при предпросмотре
    this.$('footer .unpreview').on('click', this._hidePreview);

    // предпросмотр
    this.$('footer .preview').on('click', () => {
      // подстановка данных о текущем элементе, если они есть
      const data = {};
      const itemData = this.is_inner_form ?
        this.$form.serializeHash()[this._type()] :
        this.$root.triggerWithReturn('preview:params') || {
          body: this.$textarea.val()
        };
      data[this._type()] = itemData;

      this._shade();
      return axios
        .post(
          $('footer .preview', this.$root).data('preview_url'),
          data
        )
        .then(response => this._showPreview(response.data))
        .catch()
        .then(this._unshade);
    });

    // отзыв и оффтопик
    // @$('.item-offtopic, .item-summary').click (e, data) =>
      // $button = $(e.target)
      // kind = if $button.hasClass('item-offtopic') then 'offtopic' else 'summary'
      // $button.toggleClass('selected')
      // new_value = if $button.hasClass('selected') then '1' else '0'
      // @$("#comment_#{kind}").val(new_value)

    // редактирование
    // сохранение при редактировании коммента
    this.$('.item-apply').on('click', (e, data) => this.$form.submit());

    // фокус на редакторе
    if (this.$textarea.val().length > 0) {
      // delay надо, т.к. IE не может делать focus и
      // работать с Range (внутри setCursorPosition) для невидимых элементов
      delay().then(() => {
        this.$textarea.focus();
        return this.$textarea.setCursorPosition(this.$textarea.val().length);
      });
    }

    // ajax загрузка файлов
    const fileTextPlaceholder = `[${I18n.t('frontend.shiki_editor.file')} #@]`;
    return this.$textarea.shikiFile({
      progress: $root.find('.b-upload_progress'),
      input: $('.editor-file input', $root),
      maxfiles: 6 }).on('upload:started', (e, fileNum) => {
      const fileText = fileTextPlaceholder.replace('@', fileNum);
      this.$textarea.insertAtCaret('', fileText);
      return this.$textarea.focus();
    }).on('upload:success', (e, data, fileNum) => {
      const fileText = fileTextPlaceholder.replace('@', fileNum);
      if (this.$textarea.val().indexOf(fileText) === -1) {
        this.$textarea.insertAtCaret('', `[image=${data.id}]`);
      } else {
        const text = data.id ? `[image=${data.id}]` : '';
        this.$textarea.val(this.$textarea.val().replace(fileText, text));
      }
      return this.$textarea.focus();
    }).on('upload:failed', (e, response, fileNum) => {
      const fileText = fileTextPlaceholder.replace('@', fileNum);

      if (this.$textarea.val().indexOf(fileText) !== -1) {
        this.$textarea.val(this.$textarea.val().replace(fileText, ''));
      }

      return this.$textarea.focus();
    });
  }

  _showPreview(previewHtml) {
    this.$root.addClass('previewed');
    return $('.body .preview', this.$root)
      .html(previewHtml)
      .process()
      .shikiEditor();
  }

  @bind
  _hidePreview() {
    this.$root.removeClass('previewed');
    if (!this.$('.editor-controls').is(':appeared')) { return $.scrollTo(this.$root); }
  }

  _markOfftopic(isOfftopic) {
    this.$('input[name="comment[isOfftopic]"]').val(isOfftopic ? 'true' : 'false');
    return this.$('.b-offtopic_marker').toggleClass('off', !isOfftopic);
  }

  _markReview(isReview) {
    this.$('input[name="comment[is_summary]"]').val(isReview ? 'true' : 'false');
    return this.$('.b-summary_marker').toggleClass('off', !isReview);
  }

  // очистка редактора
  cleanup() {
    this._markOfftopic(false);
    this._markReview(false);
    return this.$textarea
      .val('')
      .trigger('update');
  }

  // ответ на комментарий
  replyComment(text, isOfftopic) {
    if (isOfftopic) { this._markOfftopic(true); }

    this.$textarea
      .val(`${this.$textarea.val()}\n${text}`.replace(/^\n+/, ''))
      .focus()
      .trigger('update') // для elastic плагина
      .setCursorPosition(this.$textarea.val().length);

    return setTimeout(() => {
      if ((isMobile()) && !this.$textarea.is(':appeared')) {
        return $.scrollTo(this.$form, null, () => this.$textarea.focus());
      }
    });
  }

  // переход в режим редактирования комментария
  editComment($comment) {
    const $initialContent = $comment.children().detach();
    $comment.append(this.$root);

    // отмена редактирования
    this.$('.cancel').on('click', () => {
      this.$root.remove();
      return $comment.append($initialContent);
    });

    // замена комментария после успешного сохранения
    return this.on('ajax:success', (e, response) => $comment.view()._replace(response.html, response.JS_EXPORTS));
  }

  _type() {
    return this.$textarea.data('item_type');
  }
}
