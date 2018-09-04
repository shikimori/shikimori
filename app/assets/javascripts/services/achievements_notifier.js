import JST from 'helpers/jst';

export default class AchievementsNotifier {
  $container = null

  constructor() {
    $(document).on('faye:achievements:gained', (_e, data) =>
      this.notifyGained(data.achievements)
    );
    $(document).on('faye:achievements:lost', (_e, data) =>
      this.notifyLost(data.achievements)
    );
  }

  notifyGained(achievements) {
    this._$container().append(this._render(achievements));
    console.log('gained', achievements);
  }

  notifyLost(achievements) {
    this._$container().append(this._render(achievements));
    console.log('lost', achievements);
  }

  _$container() {
    if (!this.$container) {
      this.$container = $('<div class="b-achievements_notifier"></div>');
      $(document.body).append(this.$container);
    }
    return this.$container;
  }

  _render(achievements) {
    return JST['achievements/notification']({ achievements });
  }
}
