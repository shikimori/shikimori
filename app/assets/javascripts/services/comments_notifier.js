import delay from 'delay';

// уведомлялка о новых комментариях
// назначение класса - смотреть на странице новые комментаы и отображать информацию об этом
export default class CommentsNotifier {
  $notifier = null
  currentCounter = 0

  commentSelector = 'div.b-appear_marker.active'
  fayeLoaderSelector = '.faye-loader'

  maxTop = 31
  blockTop = 0

  constructor() {
    // при загрузке новой страницы вставляем в DOM счётчик
    $(document).on('page:load', () => this.insert());
    // при прочтении комментов, декрементим счётчик
    $(document).on('appear', (e, $appeared, byClick) => this.appear(e, $appeared, byClick));
    // при добавление блока о новом комментарии/топике делаем инкремент
    $(document).on('faye:added', () => this.incrementCounter());
    // при загрузке контента аяксом, fayer-loader'ом, postloader'ом, при перезагрузке страницы
    $(document).on(
      'page:load page:restore faye:loaded ajax:success postloader:success',
      () => this.refresh()
    );

    // явное указание о скрытии
    $(document).on('disappear', () => this.decrementCounter());
    // при добавление блока о новом комментарии/топике делаем инкремент
    $(document).on('reappear', () => this.incrementCounter());

    // смещение вверх-вниз блока уведомлялки
    this.scroll = $(window).scrollTop();

    $(window).scroll(() => {
      this.scroll = $(window).scrollTop();

      if ((this.scroll <= this.maxTop) ||
        ((this.scroll > this.maxTop) && (this.blockTop !== 0))
      ) {
        this.move();
      }
    });

    this.insert();
    this.move();
    this.refresh();
  }

  insert() {
    const alt = I18n.t('frontend.lib.comments_notifier.number_of_unread_comments');
    this.$notifier = $(`<div class='b-comments-notifier' style='display: none;' alt='${alt}'></div>`)
      .appendTo(document.body)
      .on('click', () => {
        const $firstUnread = $(`${this.commentSelector}, ${this.fayeLoaderSelector}`).first();
        $.scrollTo($firstUnread);
      });

    this.scroll = $(window).scrollTop();
  }

  async refresh() {
    await delay();
    const $commentNew = $(this.commentSelector);
    const $fayeLoader = $(this.fayeLoaderSelector);

    let count = $commentNew.length;

    $fayeLoader.each(function () {
      count += $(this).data('ids').length;
    });

    this.update(count);
  }

  update(count) {
    this.currentCounter = count;

    if (count > 0) {
      this.$notifier.show().html(this.currentCounter);
    } else {
      this.$notifier.hide();
    }
  }

  appear(e, $appeared, _byClick) {
    const $nodes = $appeared
      .filter(`${this.commentSelector}, ${this.fayeLoaderSelector}`)
      .not(function () { return $(this).data('disabled'); });

    this.update(this.currentCounter - $nodes.length);
  }

  decrementCounter() {
    this.update(this.currentCounter - 1);
  }

  incrementCounter() {
    this.update(this.currentCounter + 1);
  }

  move() {
    this.blockTop = [0, this.maxTop - this.scroll].max();
    this.$notifier.css({ top: this.blockTop });
  }
}
