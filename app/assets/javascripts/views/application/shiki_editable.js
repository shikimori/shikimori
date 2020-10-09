import delay from 'delay';
import { bind, throttle, debounce } from 'shiki-decorators';

import { getSelectionText, getSelectionHtml } from 'helpers/get_selection';
import axios from 'helpers/axios';
import { animatedCollapse } from 'helpers/animated';

import ShikiView from 'views/application/shiki_view';

const BUTTONS = [
  '.item-ignore',
  '.item-quote',
  '.item-reply',
  '.item-edit',
  '.item-summary',
  '.item-offtopic',
  '.item-cancel'
];

export default class ShikiEditable extends ShikiView {
  _reloadUrl() {
    return `/${this._type()}s/${this.node.id}`;
  }

  // внутренняя инициализация
  _initialize(...args) {
    super._initialize(...args);

    // по нажатиям на кнопки закрываем меню в мобильной версии
    this.$(BUTTONS.join(','), this.$inner).on('click', () => this._closeAside());

    $('.item-delete', this.$inner).on('click', this._showDeleteControls);
    $('.item-delete-confirm', this.$inner).on('ajax:loading', this._submitDelete);
    $('.item-delete-cancel', this.$inner).on('click', this._hideDeleteControls);

    $('.item-mobile', this.$inner).on('click', this._toggleMobileControls);

    $('.b-new_marker', this.$inner).on('click', this._markRead);

    this.on(`faye:${this._type()}:updated`, this._fayeUpdated);
    this.on(`faye:${this._type()}:deleted`, this._fayeDeleted);
  }

  // колбек после инициализации
  _afterInitialize() {
    super._afterInitialize();

    if (this.$body) {
      this.$body.on('mouseup', this.setSelection);

      $('.item-quote', this.$inner).on('click', this._itemQuote);
      $('.item-reply', this.$inner).on('click', this._itemReply);
    }
  }

  @bind
  setSelection() {
    this.throttledSetSelection();
  }

  @debounce(100)
  @throttle(100)
  async throttledSetSelection() {
    const text = getSelectionText();
    const html = getSelectionHtml();
    if (!text && !html) { return; }

    // скрываем все кнопки цитаты
    $('.item-quote').hide();

    this.$node.data({
      selected_text: text,
      selected_html: html
    });
    const $quote = $('.item-quote', this.$inner).css({ display: 'inline-block' });

    await delay();
    $(document).one('click', async () => {
      if (!getSelectionText().length) {
        $quote.hide();
        return;
      }

      await delay(250);
      if (!getSelectionText().length) {
        $quote.hide();
      }
    });
  }

  _activateAppearMarker() {
    this.$inner.children('.b-appear_marker').addClass('active');
    this.$inner.children('.markers').find('.b-new_marker').addClass('active');
  }

  // закрытие кнопок в мобильной версии
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
    $.hideCursorMessage();
    await animatedCollapse(this.node);
    this.$node.remove();
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
      user_id: this.$node.data('user_id'),
      nickname: this.$node.data('user_nickname'),
      text: this.$node.data('selected_text'),
      html: this.$node.data('selected_html')
    };
    const isOfftopic = typeof this._isOfftopic === 'function' ?
      this._isOfftopic() :
      false;

    this.$node.trigger('comment:reply', [quote, isOfftopic]);
  }

  @bind
  _itemReply() {
    const reply = {
      id: this.node.id,
      type: this._type(),
      text: this.$node.data('user_nickname'),
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
