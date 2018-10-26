import JST from 'helpers/jst';
import delay from 'delay';

const MAXIMUM_ACHIEVEMETNS = 7;

export default class AchievementsNotifier {
  $container = null
  achievementsToNotify = []

  constructor() {
    $(document).on('faye:achievements', (_e, data) =>
      this.notify(data.achievements)
    );
  }

  notify(achievements) {
    if (achievements.length > MAXIMUM_ACHIEVEMETNS) { return; }

    achievements.forEach(async (achievement, index) => {
      if (index > 0) {
        await delay(750 * index);
      }
      const $achievement = $(this._render(achievement))
        .addClass('appearing')
        .appendTo(this._$container())
        .on('click', async ({ target }) => {
          if (target.tagName === 'A') { return; }
          if ($achievement.hasClass('removing')) { return; }

          $achievement.addClass('removing');
          await delay(1000);
          $achievement.remove();
        });

      await delay();
      $achievement.removeClass('appearing');

      await delay(30000);
      $achievement.click();
    });
  }

  _$container() {
    if (!this.$container) {
      this.$container = $('<div class="b-achievements_notifier"></div>');
      $(document.body).append(this.$container);
    }
    return this.$container;
  }

  _render(achievement, event) {
    return JST['achievements/notifier']({ achievement, event });
  }
}
