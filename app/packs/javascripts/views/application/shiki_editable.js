import delay from 'delay';
import { bind, debounce, memoize } from 'shiki-decorators';
import { flash, isMobile } from 'shiki-utils';

import { getSelectionText, getSelectionHtml } from '@/utils/get_selection';
import axios from '@/utils/axios';
import { animatedCollapse } from '@/utils/animated';

import BanForm from '@/views/application/ban_form';
import ShikiView from '@/views/application/shiki_view';

const BUTTONS = [
  '.item-ignore',
  '.item-quote',
  '.item-reply',
  '.item-edit',
  '.item-summary', // aka review_convert
  '.item-offtopic',
  '.item-cancel',
  '.item-spoiler',
  '.item-abuse'
];
const ABUSE_REQUEST_BUTTONS = [
  '.item-summary', // aka review_convert
  '.item-offtopic',
  '.item-spoiler',
  '.item-abuse',
  '.b-offtopic_marker'
];
const ITEM_QUOTE_SELECTOR = '.item-quote, .item-quote-mobile';
const I18N_KEY = 'frontend.dynamic_elements.shiki_editable';

export default class ShikiEditable extends ShikiView {
  // внутренняя инициализация
  _initialize(...args) {
    super._initialize(...args);

    // по нажатиям на кнопки закрываем меню в мобильной версии
    $(BUTTONS.join(','), this.$inner).on('click', this._closeAside);

    this._bindDeleteControls();
    this._bindEditControls();
    this._bindModerationControls();
    this._bindAbuseRequestControls();
    this._bindFaye();
    this._bindAutoExpand();

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

  get reloadUrl() {
    return `/${this.type}s/${this.node.id}`;
  }

  @memoize
  get isGenerated() {
    return !!this.$node.data('generated');
  }

  get $editorPlacement() {
    return this.$inner;
  }

  get $moderationForm() {
    return $('.moderation-ban-form', this.$inner);
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

    // hide comment markers to prevent overlapping with quote button
    if (isMobile()) {
      const markers = $(ITEM_QUOTE_SELECTOR, this.$inner).parent().find('aside.markers').children();
      markers.each((_, node) => {
        if ($(node).css('display') == 'block') {
          $(node).hide();
          $(node).addClass('temporarily-hidden-markers');
        }
      });
    }

    await delay();
    $(document).one('click', async () => {
      if (!getSelectionText().length) {
        $quote.removeClass('is-active');
        $('.temporarily-hidden-markers').show().removeClass('temporarily-hidden-markers');
        return;
      }

      await delay(250);
      if (!getSelectionText().length) {
        $('.temporarily-hidden-markers').show().removeClass('temporarily-hidden-markers');
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
    $('.item-edit', this.$inner)
      .on('ajax:before', this._shade)
      .on('ajax:complete', this._unshade)
      .on('ajax:success', this._edit);
  }

  _bindModerationControls() {
    $('.item-ban', this.$inner)
      .on('ajax:before', this._shade)
      .on('ajax:complete', this._unshade)
      .on('ajax:success', this._showModerationForm);
    $('.item-moderation', this.$inner).on('click', this._showModrationControls);
    $('.item-moderation-cancel', this.$inner).on('click', this._hideModerationControls);

    this.$inner.one('mouseover', this._deactivateInaccessibleButtons);
    $('.item-mobile', this.$inner).one('click', this._deactivateInaccessibleButtons);
  }

  _bindAbuseRequestControls() {
    $(ABUSE_REQUEST_BUTTONS.join(','), this.$inner)
      .on('ajax:before', this._shade)
      .on('ajax:complete', this._unshade)
      .on('ajax:success', this._processAbuseRequest);

    $('.item-spoiler, .item-abuse', this.$inner).on('ajax:before', this._markSpoilerOrAbuse);
  }

  _bindFaye() {
    this.on(`faye:${this.type}:updated`, this._fayeUpdated);
    this.on(`faye:${this.type}:deleted`, this._fayeDeleted);
  }

  _bindAutoExpand() {
    this.$inner.on('ajax:before', () => {
      this.$inner.next('.b-height_shortener').click();
    });
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
    this.$inner.addClass('is-editing');

    const $form = $(html).process();

    const $initialContent = this.$editorPlacement.children().detach();
    $form.appendTo(this.$editorPlacement);

    const editor = $form.find('.shiki_editor-selector').view();
    editor.initialization.promise.then(() => editor.focus());

    // отмена редактирования
    $form.find('.cancel').on('click', () => {
      editor.destroy();
      $form.remove();
      this.$editorPlacement.append($initialContent);
      this.$inner.removeClass('is-editing');
    });

    // замена комментария после успешного сохранения
    $form.on('ajax:success', (_e, response) => (
      this._replace(response.content, response.JS_EXPORTS, true)
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
  _showModrationControls() {
    $('.main-controls', this.$inner).hide();
    $('.moderation-controls', this.$inner).show();
  }

  @bind
  _hideModerationControls() {
    this._closeAside();
  }

  @bind
  _deactivateInaccessibleButtons() {
    if (!this.model.can_edit) { $('.item-edit', this.$inner).addClass('hidden'); }
    if (!this.model.can_destroy) { $('.item-delete', this.$inner).addClass('hidden'); }

    if (window.SHIKI_USER.isModerator) {
      $('.item-abuse', this.$inner).addClass('hidden');
      $('.item-spoiler', this.$inner).addClass('hidden');
    } else {
      $('.item-ban', this.$inner).addClass('hidden');
    }
  }

  @bind
  _processAbuseRequest(_e, _data, isShowFlash = true) {
    if (isShowFlash) {
      flash.notice(I18n.t(`${I18N_KEY}.your_request_will_be_considered`));
    }
    this._hideModerationControls();
  }

  @bind
  async _showModerationForm(e, html) {
    const form = new BanForm(html);

    this.$moderationForm.remove();
    $('<aside class="moderation-ban-form"></aside>').insertBefore(
      this.$inner.find('aside.buttons')
    );
    this.$moderationForm.html(form.$node);

    $('.cancel', this.$moderationForm).on('click', this._hideModerationForm);
    $('form', this.$moderationForm).on('ajax:success', this._processModerationRequest);

    this.$inner.addClass('is-moderating');
    this._closeAside();

    await delay(250);
    this.$moderationForm.find('input[type=text]').first().focus();
  }

  @bind
  _hideModerationForm() {
    this.$moderationForm.hide();
  }

  @bind
  _processModerationRequest(_e, response) {
    this._replace(response.content, response.JS_EXPORTS, true);
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
      const $appears = $('.b-appear_marker.active', this.$inner);
      $appears.trigger('appear', [$appears, true]);
    }
  }

  @bind
  _itemQuote() {
    const quote = {
      id: this.node.id,
      type: this.type,
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
      type: this.type,
      userId: this.$node.data('user_id'),
      text: String(this.$node.data('user_nickname')),
      url: this.$node.data('url') || `/${this.type}s/${this.node.id}`
    };
    const isOfftopic = typeof this._isOfftopic === 'function' ?
      this._isOfftopic() :
      false;

    this.$node.trigger('comment:reply', [reply, isOfftopic]);
  }

  @bind
  _markSpoilerOrAbuse({ currentTarget }) {
    const reason = prompt($(currentTarget).data('reason-prompt'));

    // return value grabbed by triggerAndReturn in rauils_ujs
    if (reason == null) { return false; }

    $(currentTarget).data({ form: { reason } });
    return true;
  }

  @bind
  _fayeUpdated(_e, data) {
    $('.was_updated', this.$inner).remove();

    const message = this.type === 'message' ?
      `${this.typeLabel} ${I18n.t('frontend.shiki_editable.message_changed')}` :
      `${this.typeLabel} ${I18n.t('frontend.shiki_editable.changed')}`;

    const $notice = $(
      `<div class='was_updated'><div><span>${message}</span>` +
      `<a class='actor b-user16' href='/${data.actor}'>` +
      `<img src='${data.actor_avatar}' srcset='${data.actor_avatar_2x} 2x' />` +
      `<span>${data.actor}</span></a>.&nbsp;</div>` +
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
    const message = this.type === 'message' ?
      `${this.typeLabel} ${I18n.t('frontend.shiki_editable.message_deleted')}` :
      `${this.typeLabel} ${I18n.t('frontend.shiki_editable.deleted')}`;

    this._replace(
      `<div class='b-comment-info b-${this.type}'><span>${message}</span>` +
      `<a class='b-user16' href='/${data.actor}'><img src='${data.actor_avatar}' ` +
      `srcset='${data.actor_avatar_2x} 2x' /><span>${data.actor}</span></a></div>`
    );

    return false; // очень важно! иначе эвенты зациклятся из-за такого же обработчика в родителе
  }
}
