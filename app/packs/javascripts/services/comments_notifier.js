import { bind } from 'shiki-decorators';
import delay from 'delay';

import JST from '@/utils/jst';

const COMMENT_SELECTOR = 'div.b-appear_marker.active';
const FAYE_LOADER_SELECTOR = '.faye-loader';
const TRACK_EVENTS = [
  'turbolinks:load',
  'faye:loaded',
  'ajax:success',
  'postloader:success',
  'clickloaded:success'
];

// уведомлялка о новых комментариях
// назначение класса - смотреть на странице новые комментаы и отображать информацию об этом
export default class CommentsNotifier {
  $container = null
  currentCounter = 0

  maxTop = 48
  blockTop = 0

  constructor() {
    $(document).on('turbolinks:before-cache', this._cleanup);
    $(document).on('appear', this._appear);
    $(document).on('faye:added', this._incrementCounter);
    $(document).on(TRACK_EVENTS.join(' '), this._refresh);

    // явное указание о скрытии
    $(document).on('disappear', this._decrementCounter);
    // при добавление блока о новом комментарии/топике делаем инкремент
    $(document).on('reappear', this._incrementCounter);

    this._refresh();

    $(window).scroll(() => {
      if (!this.$container || this.isStickyMenu) { return; }

      this.scroll = $(window).scrollTop();

      if ((this.scroll <= this.maxTop) ||
        ((this.scroll > this.maxTop) && (this.blockTop !== 0))
      ) {
        this._move();
      }
    });
  }

  _$container() {
    if (!this.$container) {
      this.$container = $(this._render())
        .appendTo(document.body)
        .on('click', () => {
          const $firstUnread = $(`${COMMENT_SELECTOR}, ${FAYE_LOADER_SELECTOR}`).first();
          const firstUnreadNode = $firstUnread.closest('[data-appear_type]');

          $.scrollTo(firstUnreadNode || $firstUnread);
        });

      this.scroll = $(window).scrollTop();
    }

    return this.$container;
  }

  _render() {
    return JST['comments/notifier']();
  }

  @bind
  _cleanup() {
    if (this.$container) {
      this.$container.remove();
      this.$container = null;
    }
  }

  @bind
  async _refresh() {
    await delay();

    this.scroll = $(window).scrollTop();
    this.isStickyMenu = $('.l-top_menu-v2').css('position') === 'sticky';

    const $commentNew = $(COMMENT_SELECTOR);
    const $fayeLoader = $(FAYE_LOADER_SELECTOR);

    let count = $commentNew.length;

    $fayeLoader.each(function() {
      count += $(this).data('ids')?.length || 0;
    });

    this._update(count);
  }

  _update(count) {
    this.currentCounter = count;

    if (count > 0) {
      this._$container().show().html(this.currentCounter);
    } else if (this.$container) {
      this._$container().hide();
    }
  }

  @bind
  _appear(e, $appeared, _byClick) {
    const $nodes = $appeared
      .filter(`${COMMENT_SELECTOR}, ${FAYE_LOADER_SELECTOR}`)
      .not(function() { return $(this).data('disabled'); });

    this._update(this.currentCounter - $nodes.length);
  }

  @bind
  _decrementCounter({ target }) {
    if (target.attributes['data-disabled'] && target.attributes['data-disabled'].value === 'true') {
      return;
    }
    this._update(this.currentCounter - 1);
  }

  @bind
  _incrementCounter() {
    this._update(this.currentCounter + 1);
  }

  _move() {
    this.blockTop = [0, this.maxTop - this.scroll].max();
    this._$container().css({ top: this.blockTop });
  }
}
