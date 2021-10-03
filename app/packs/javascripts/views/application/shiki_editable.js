import delay from 'delay';
import { bind, debounce, memoize, throttle } from 'shiki-decorators';

import { getSelectionText, getSelectionHtml } from '@/utils/get_selection';
import axios from '@/utils/axios';
import { animatedCollapse } from '@/utils/animated';

import ShikiView from '@/views/application/shiki_view';

const BUTTONS = [
  '.item-ignore',
  '.item-quote',
  '.item-reply',
  '.item-edit',
  '.item-summary',
  '.item-offtopic',
  '.item-cancel'
];
const ITEM_QUOTE_SELECTOR = '.item-quote, .item-quote-mobile';

export default class ShikiEditable extends ShikiView {
  _reloadUrl() {
    return `/${this._type()}s/${this.node.id}`;
  }

  // внутренняя инициализация
  _initialize(...args) {
    super._initialize(...args);

    // по нажатиям на кнопки закрываем меню в мобильной версии
    this.$(BUTTONS.join(','), this.$inner).on('click', this._closeAside);

    this._bindDeleteControls();
    this._bindEditControls();
    this._bindFaye();

    $('.item-mobile', this.$inner).on('click', this._toggleMobileControls);
    $('.b-new_marker', this.$inner).on('click', this._markRead);
  }

  // колбек после инициализации
  _afterInitialize() {
    super._afterInitialize();

    if (this.$body) {
      this.$body.on('mouseup', this.setSelection);

      $(ITEM_QUOTE_SELECTOR, this.$inner).on('click', this._itemQuote);
      $('.item-reply', this.$inner).on('click', this._itemReply);
    }
  }

  @memoize
  get isGenerated() {
    return !!this.$node.data('generated');
  }

  @bind
  setSelection() {
    this.throttledSetSelection();
  }

  @debounce(150)
  async throttledSetSelection() {
    const text = getSelectionText();
    const html = getSelectionHtml();
    if (!text && !html) { return; }

    // скрываем все кнопки цитаты
    $(ITEM_QUOTE_SELECTOR).removeClass('is-active');

    this.$node.data({
      selected_text: text,
      selected_html: html
    });
    const $quote = $(ITEM_QUOTE_SELECTOR, this.$inner).addClass('is-active');

    await delay();
    $(document).one('click', async () => {
      if (!getSelectionText().length) {
        $quote.removeClass('is-active');
        return;
      }

      await delay(250);
      if (!getSelectionText().length) {
        $quote.removeClass('is-active');
      }
    });
  }

  _bindDeleteControls() {
    $('.item-delete', this.$inner).on('click', this._showDeleteControls);
    $('.item-delete-confirm', this.$inner).on('ajax:loading', this._submitDelete);
    $('.item-delete-confirm', this.$inner).on('ajax:success', this._redirectAfterDeleted);
    $('.item-delete-cancel', this.$inner).on('click', this._hideDeleteControls);
  }

  _bindEditControls() {
    $('.main-controls .item-edit', this.$inner)
      .on('ajax:before', this._shade)
      .on('ajax:complete', this._unshade)
      .on('ajax:success', this._edit);
  }

  _bindFaye() {
    this.on(`faye:${this._type()}:updated`, this._fayeUpdated);
    this.on(`faye:${this._type()}:deleted`, this._fayeDeleted);
  }

  _activateAppearMarker() {
    this.$inner.children('.b-appear_marker').addClass('active');
    this.$inner.children('.markers').find('.b-new_marker').addClass('active');
  }

  // закрытие кнопок в мобильной версии
  @bind
  _closeAside() {
    if ($('.item-mobile', this.$inner).is('.selected')) {
      // ">" need because in dialogs we may have nested inner element
      $('> .item-mobile', this.$inner).click();
    }

    $('.main-controls', this.$inner).show();
    $('.delete-controls', this.$inner).hide();
    $('.moderation-controls', this.$inner).hide();
  }

  @bind
  _edit(e, html, _status, _xhr) {
    const $form = $(html).process();

    const $initialContent = this.$inner.children().detach();
    $form.appendTo(this.$inner);

    const editor = $form.find('.shiki_editor-selector').view();
    editor.initialization.promise.then(() => editor.focus());

    // отмена редактирования
    $form.find('.cancel').on('click', () => {
      editor.destroy();
      $form.remove();
      this.$inner.append($initialContent);
    });

    // замена комментария после успешного сохранения
    $form.on('ajax:success', (_e, response) => (
      this._replace(response.html, response.JS_EXPORTS)
    ));
  }

  @bind
  _showDeleteControls() {
    $('.main-controls', this.$inner).hide();
    $('.delete-controls', this.$inner).show();
  }

  @bind
  _hideDeleteControls() {
    this._closeAside();
  }

  @bind
  async _submitDelete() {
    await animatedCollapse(this.node);
    this.$node.remove();
  }

  // can be overridden in inherited classes
  @bind
  _redirectAfterDeleted() {
  }

  @bind
  _toggleMobileControls() {
    this.$node.toggleClass('aside-expanded');
    $('.item-mobile', this.$inner).toggleClass('selected');

    // из-за снятия overflow для элемента с .aside-expanded,
    // сокращённая высота работает некорректно, поэтому её надо убрать
    this.$node.find('>.b-height_shortener').click();
  }

  @bind
  _markRead() {
    const $newMarker = $('.b-new_marker.active', this.$inner);

    if ($newMarker.hasClass('off')) {
      $newMarker
        .removeClass('off')
        .data('click_activated', true)
        .trigger('reappear');

      axios.post($newMarker.data('reappear_url'), { ids: this.$node.attr('id') });
    } else if ($newMarker.data('click_activated')) {
      $newMarker
        .addClass('off')
        .trigger('disappear');

      axios.post($newMarker.data('appear_url'), { ids: this.$node.attr('id') });
    } else {
      // эвент appear обрабатывается в topic
      const $appears = this.$('.b-appear_marker.active');
      $appears.trigger('appear', [$appears, true]);
    }
  }

  @bind
  _itemQuote() {
    const quote = {
      id: this.node.id,
      type: this._type(),
      userId: this.isGenerated ? null : this.$node.data('user_id'),
      nickname: this.isGenerated ? null : String(this.$node.data('user_nickname')),
      text: String(this.$node.data('selected_text')),
      html: String(this.$node.data('selected_html'))
    };
    const isOfftopic = typeof this._isOfftopic === 'function' ?
      this._isOfftopic() :
      false;

    this.$node.trigger('comment:reply', [quote, isOfftopic]);
  }

  @bind
  _itemReply() {
    if (this.isGenerated) {
      this.$node.trigger('comment:reply');
      return;
    }

    const reply = {
      id: this.node.id,
      type: this._type(),
      userId: this.$node.data('user_id'),
      text: String(this.$node.data('user_nickname')),
      url: this.$node.data('url') || `/${this._type()}s/${this.node.id}`
    };
    const isOfftopic = typeof this._isOfftopic === 'function' ?
      this._isOfftopic() :
      false;

    this.$node.trigger('comment:reply', [reply, isOfftopic]);
  }

  @bind
  _fayeUpdated(_e, data) {
    $('.was_updated', this.$inner).remove();

    const message = this._type() === 'message' ?
      `${this._typeLabel()} ${I18n.t('frontend.shiki_editable.message_changed')}` :
      `${this._typeLabel()} ${I18n.t('frontend.shiki_editable.changed')}`;

    const $notice = $(
      `<div class='was_updated'><div><span>${message}</span>` +
      `<a class='actor b-user16' href='/${data.actor}'>` +
      `<img src='${data.actor_avatar}' srcset='${data.actor_avatar_2x} 2x' />` +
      `<span>${data.actor}</span></a>.</div>` +
      `<div>${I18n.t('frontend.shiki_editable.click_to_reload')}</div></div>`
    );

    $notice
      .appendTo(this.$inner)
      .on('click', ({ target }) => {
        if (!$(target).closest('.actor').exists()) {
          this._reload();
        }
      });

    return false; // очень важно! иначе эвенты зациклятся из-за такого же обработчика в родителе
  }

  @bind
  _fayeDeleted(_e, data) {
    const message = this._type() === 'message' ?
      `${this._typeLabel()} ${I18n.t('frontend.shiki_editable.message_deleted')}` :
      `${this._typeLabel()} ${I18n.t('frontend.shiki_editable.deleted')}`;

    this._replace(
      `<div class='b-comment-info b-${this._type()}'><span>${message}</span>` +
      `<a class='b-user16' href='/${data.actor}'><img src='${data.actor_avatar}' ` +
      `srcset='${data.actor_avatar_2x} 2x' /><span>${data.actor}</span></a></div>`
    );

    return false; // очень важно! иначе эвенты зациклятся из-за такого же обработчика в родителе
  }
}
