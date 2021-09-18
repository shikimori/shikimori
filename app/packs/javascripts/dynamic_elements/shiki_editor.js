import delay from 'delay';
import pDefer from 'p-defer';
import { bind } from 'shiki-decorators';
import { flash } from 'shiki-utils';

import axios from '@/helpers/axios';
import preventEvent from '@/helpers/prevent_event';
import ShikiView from '@/views/application/shiki_view';

import { isMobile } from 'shiki-utils';

// TODO: refactor constructor
export default class ShikiEditor extends ShikiView {
  initialization = pDefer()

  async initialize() {
    const { $node } = this;
    this.$form = $node.closest('form');
    this.isInnerForm = false;

    this.$textarea = this.$('textarea');

    // при вызове фокуса на shiki-editor передача сообщения в редактор
    this.on('focus', focus);

    await import(/* webpackChunkName: "shiki_editor_v1" */ 'paste.js');
    const { default: autosize } = await import(
      /* webpackChunkName: "shiki_editor_v1" */ 'autosize'
    );

    // по первому фокусу на редактор включаем autosize
    this.$textarea.one('focus', () => delay().then(() => autosize(this.$textarea[0])));
    this.$textarea.on('keypress keydown', this._onKeyPress);

    this.$form
      .on('ajax:before', () => {
        if (this.text.replace(/\n| |\r|\t/g, '')) {
          this._shade();
          return;
        }
        flash.error(I18n.t('frontend.shiki_editor.text_cant_be_blank'));
        return false;
      }).on('ajax:complete', this._unshade)
      .on('ajax:success', async () => {
        this._hidePreview();
        await delay();
        this.$textarea[0].dispatchEvent(new Event('autosize:update'));
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
      `[spoiler=${I18n.t('frontend.shiki_editor.spoiler').toLowerCase()}]`,
      '[/spoiler]'
    ));

    // смайлики и ссылка
    ['smiley', 'link', 'image', 'quote', 'upload'].forEach(key => (
      this.$(`.editor-${key}`).on('click', e => {
        const $button = $(e.target);
        const $block = this.$(`.${key}s`);

        if ($button.hasClass('selected')) {
          $block.addClass('hidden');
        } else {
          $block.removeClass('hidden');
          $block.trigger('click:open');
        }

        $button.toggleClass('selected');
      })
    ));

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
      $('.links input[type=text]', $node).val('');

      $(this.$('[name="link_type"]:checked')[0] || this.$('[name="link_type"]')[0])
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
    this.$('.links input[type=radio]').on('change', function() {
      const $this = $(this);
      const $input = $('.links input[type=text]', $node);
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
    this.$('.links input[type=radio]').on('tag:build', (_e, _data) => (
      this.$('.editor-link').trigger('click')
    ));

    // открытие блока картинки
    this.$('.images').on('click:open', () =>
      // чистим текущий введённый текст
      this.$('.images input[type=text]').val('').focus()
    );

    // сабмит картинки в текстовом поле
    this.$('.images input[type=text]').on('keypress', (e, isForceSubmit) => {
      if ((e.keyCode === 10) || (e.keyCode === 13) || isForceSubmit) {
        preventEvent(e);

        this.$textarea.insertAtCaret('', `[img]${$(e.target).val()}[/img]`);
        this.$('.editor-image').trigger('click');
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
        preventEvent(e);

        this.$textarea.insertAtCaret(
          '[quote' +
            ((!this.value || this.value.isBlank() ? '' : `=${this.value}`)) +
            ']',
          '[/quote]'
        );
        this.$('.editor-quote').trigger('click');
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
        this.$('.editor-quote').trigger('click');
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

    this.$('.smileys').one('click:open', this._loadSmileys);

    this.$('.b-offtopic_marker').on('click', this._onMarkOfftopic);
    this.$('.b-summary_marker').on('click', this._onMarkCritique);

    this.$('footer .unpreview').on('click', this._hidePreview);
    this.$('footer .preview').on('click', () => {
      // подстановка данных о текущем элементе, если они есть
      const data = {};

      const itemData = {
        ...(this.$node.data('preview_params') || {}),
        body: this.text
      };
      data[this.type] = itemData;

      this._shade();
      axios
        .post(
          $('footer .preview', this.$node).data('preview_url'),
          data
        )
        .then(response => this._showPreview(response.data))
        .catch()
        .then(this._unshade);
    });

    // редактирование
    // сохранение при редактировании коммента
    this.$('.item-apply').on('click', (_e, _data) => this.$form.submit());

    // фокус на редакторе
    if (this.text.length > 0) {
      // delay надо, т.к. IE не может делать focus и
      // работать с Range (внутри setCursorPosition) для невидимых элементов
      delay().then(() => {
        this.$textarea.focus();
        this.$textarea.setCursorPosition(this.text.length);
      });
    }

    // ajax загрузка файлов
    const fileTextPlaceholder = `[${I18n.t('frontend.shiki_editor.file')} #@]`;
    this.$textarea
      .shikiFile({
        progress: $node.find('.b-upload_progress'),
        input: $('.editor-file input', $node),
        maxfiles: 6
      })
      .on('upload:started', (e, fileNum) => {
        const fileText = fileTextPlaceholder.replace('@', fileNum);

        this.$textarea.insertAtCaret('', fileText);
        this.$textarea.focus();
      })
      .on('upload:success', (e, data, fileNum) => {
        const fileText = fileTextPlaceholder.replace('@', fileNum);

        if (this.text.indexOf(fileText) === -1) {
          this.$textarea.insertAtCaret('', `[image=${data.id}]`);
        } else {
          const text = data.id ? `[image=${data.id}]` : '';
          this.$textarea.val(this.text.replace(fileText, text));
        }

        this.$textarea.focus();
      })
      .on('upload:failed', (e, response, fileNum) => {
        const fileText = fileTextPlaceholder.replace('@', fileNum);

        if (this.text.indexOf(fileText) !== -1) {
          this.$textarea.val(this.text.replace(fileText, ''));
        }

        this.$textarea.focus();
      });

    delay().then(() => this.initialization.resolve());
  }

  get type() {
    return this.$textarea.data('item_type');
  }

  get text() {
    return this.$textarea.val();
  }

  _showPreview(previewHtml) {
    this.$node.addClass('previewed');
    $('.body .preview', this.$node)
      .html(previewHtml)
      .process();
  }

  @bind
  _hidePreview() {
    this.$node.removeClass('previewed');

    if (!this.$('.editor-controls').is(':appeared') && this.$node.is(':visible')) {
      $.scrollTo(this.$node);
    }
  }

  @bind
  _onMarkOfftopic() {
    this._markOfftopic(
      this.$('.b-offtopic_marker').hasClass('off')
    );
  }

  @bind
  _onMarkCritique() {
    this._markCritique(
      this.$('.b-summary_marker').hasClass('off')
    );
  }

  @bind
  _loadSmileys() {
    const $smileys = this.$('.smileys');

    $smileys.load($smileys.data('href'), () => {
      this.$('.smileys img').on('click', ({ currentTarget }) => {
        const bbCode = $(currentTarget).attr('alt');

        this.$textarea.insertAtCaret('', bbCode);
        this.$('.editor-smiley').trigger('click');
      });
    });
  }

  @bind
  _onKeyPress(e) {
    if (e.keyCode === 27) { // esc
      preventEvent(e);
      this.$textarea.blur();
    }
    if (!e.metaKey && !e.ctrlKey) { return; }

    if ((e.keyCode === 10) || (e.keyCode === 13)) { // ctrl+enter - save
      preventEvent(e);
      this.$form.submit();
    } if (e.keyCode === 66) { // b - [b] tag
      preventEvent(e);
      this.$('.editor-bold').click();
    } if (e.keyCode === 73) { // i - [i] tag
      preventEvent(e);
      this.$('.editor-italic').click();
    } if (e.keyCode === 85) { // u - [u] tag
      preventEvent(e);
      this.$('.editor-underline').click();
    } if (e.keyCode === 83) { //  - spoiler tag
      preventEvent(e);
      this.$('.editor-spoiler').click();
    } if (e.keyCode === 79) { // o - code tag
      preventEvent(e);
      this.$textarea.insertAtCaret('[code]', '[/code]');
    }
  }

  _markOfftopic(isOfftopic) {
    this.$form.find('input[name="comment[is_offtopic]"]').val(isOfftopic ? 'true' : 'false');
    this.$('.b-offtopic_marker').toggleClass('off', !isOfftopic);
  }

  _markCritique(isCritique) {
    this.$form.find('input[name="comment[is_summary]"]').val(isCritique ? 'true' : 'false');
    this.$('.b-summary_marker').toggleClass('off', !isCritique);
  }

  @bind
  focus() {
    this.$textarea.focus();
  }

  // очистка редактора
  cleanup() {
    this._markOfftopic(false);
    this._markCritique(false);

    this.$textarea
      .val('')
      .trigger('update');
  }

  // ответ на комментарий
  async replyComment({ id, type, userId, nickname, text, url }, isOfftopic) {
    if (isOfftopic) { this._markOfftopic(true); }

    let reply;

    if (url) {
      const ids = [id, userId].compact();
      reply = `[${type}=${ids.join(';')}], `;
    } else {
      const ids = [id, userId, nickname];
      const type0 = type[0];
      const prefix = userId ? `=${type0}${ids.join(';')}` : '';

      reply = `[quote${prefix}]${text}[/quote]\n`;
    }

    this.$textarea
      .val(`${this.text}\n${reply}`.replace(/^\n+/, ''))
      .focus()
      .trigger('update') // для elastic плагина
      .setCursorPosition(this.text.length);

    await delay();
    if ((isMobile()) && !this.$textarea.is(':appeared')) {
      $.scrollTo(this.$form, null, this.focus);
    }
  }

  // added for compatibility with shiki-editor
  destroy() {
  }
}
