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
  // inner initialization
  _initialize(...args) {
    super._initialize(...args);
    let $newMarker = $('.b-new_marker', this.$inner);

    // по нажатиям на кнопки закрываем меню в мобильной версии
    this.$(BUTTONS.join(','), this.$inner).on('click', () => this._close_aside());

    // deletion
    $('.item-delete', this.$inner).on('click', () => {
      $('.main-controls', this.$inner).hide();
      $('.delete-controls', this.$inner).show();
    });

    // confirm deletion
    $('.item-delete-confirm', this.$inner).on('ajax:loading', async (_e, _data, _status, _xhr) => {
      $.hideCursorMessage();
      await animatedCollapse(this.root);
      this.$root.remove();
    });

    // cancel deletion
    $('.item-delete-cancel', this.$inner).on('click', () =>
      // @$('.main-controls').show()
      // @$('.delete-controls').hide()
      this._close_aside()
    );

    // переключение на мобильую версию кнопок кнопок
    $('.item-mobile', this.$inner).on('click', () => {
      this.$root.toggleClass('aside-expanded');
      $('.item-mobile', this.$inner).toggleClass('selected');
      // из-за снятия overflow для элемента с .aside-expanded,
      // сокращённая высота работает некорректно, поэтому её надо убрать
      this.$root.find('>.b-height_shortener').click();
    });

    // по клику на 'новое' пометка прочитанным
    $newMarker.on('click', () => {
      $newMarker = $('.b-new_marker.active', this.$inner);

      if ($newMarker.hasClass('off')) {
        $newMarker
          .removeClass('off')
          .data({ click_activated: true })
          .trigger('reappear');

        axios.post($newMarker.data('reappear_url'), { ids: this.$root.attr('id') });
        return;
      } if ($newMarker.data('click_activated')) {
        $newMarker
          .addClass('off')
          .trigger('disappear');

        axios.post($newMarker.data('appear_url'), { ids: this.$root.attr('id') });
        return;
      }

      // эвент appear обрабатывается в topic
      const $appears = this.$('.b-appear_marker.active');
      $appears.trigger('appear', [$appears, true]);
    });

    // realtime уведомление об изменении
    this.on(`faye:${this._type()}:updated`, (e, data) => {
      $('.was_updated', this.$inner).remove();

      const message = this._type() === 'message' ?
        `${this._type_label()} ${I18n.t('frontend.shiki_editable.message_changed')}` :
        `${this._type_label()} ${I18n.t('frontend.shiki_editable.changed')}`;

      const $notice = $(
        `<div class='was_updated'><div><span>${message}</span>` +
        `<a class='actor b-user16' href='/${data.actor}'><img ` +
        `src='${data.actor_avatar}' srcset='${data.actor_avatar_2x} 2x' />` +
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
      return false;
    }); // очень важно! иначе эвенты зациклятся из-за такого же обработчика в родителе

    // realtime уведомление об удалении
    this.on(`faye:${this._type()}:deleted`, (e, data) => {
      const message = this._type() === 'message' ?
        `${this._type_label()} ${I18n.t('frontend.shiki_editable.message_deleted')}` :
        `${this._type_label()} ${I18n.t('frontend.shiki_editable.deleted')}`;

      this._replace(
        `<div class='b-comment-info b-${this._type()}'><span>${message}</span>` +
        `<a class='b-user16' href='/${data.actor}'><img src='${data.actor_avatar}' ` +
        `srcset='${data.actor_avatar_2x} 2x' /><span>${data.actor}</span></a></div>`
      );
      return false;
    }); // очень важно! иначе эвенты зациклятся из-за такого же обработчика в родителе
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

    this.$root.data({
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

  _after_initialize() { // eslint-disable-line camelcase
    super._after_initialize();

    if (this.$body) {
      this.$body.on('mouseup', this.setSelection);

      $('.item-quote', this.$inner).on('click', _e => {
        this.$root.trigger(
          'comment:reply',
          [
            {
              id: this.$root.prop('id'),
              type: this._type(),
              user_id: this.$root.data('user_id'),
              nickname: this.$root.data('user_nickname'),
              text: this.$root.data('selected_text'),
              html: this.$root.data('selected_html')
            },
            this?._is_offtopic() // eslint-disable-line camelcase
          ]
        );
      });
    }
  }

  _activate_appear_marker() { // eslint-disable-line camelcase
    this.$inner.children('.b-appear_marker').addClass('active');
    this.$inner.children('.markers').find('.b-new_marker').addClass('active');
  }

  // закрытие кнопок в мобильной версии
  _close_aside() { // eslint-disable-line camelcase
    // ">" need because in dialogs we may have nested inner element
    if ($('.item-mobile', this.$inner).is('.selected')) {
      $('> .item-mobile', this.$inner).click();
    }

    $('.main-controls', this.$inner).show();
    $('.delete-controls', this.$inner).hide();
    $('.moderation-controls', this.$inner).hide();
  }

  @bind
  _reload_url() { // eslint-disable-line camelcase
    return `/${this._type()}s/${this.$root.attr('id')}`;
  }
}
