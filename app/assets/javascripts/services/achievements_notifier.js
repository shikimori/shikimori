import JST from 'helpers/jst';
import delay from 'delay';

const MAXIMUM_ACHIEVEMETNS = 7;

export default class AchievementsNotifier {
  $container = null

  constructor() {
    $(document).on('faye:achievements:gained faye:achievements:lost', (e, data) =>
      this.notify(data.achievements, e.type.split(':').last())
    );
  }

  notify(achievements, event) {
    if (achievements.length > MAXIMUM_ACHIEVEMETNS) { return; }

    achievements.forEach(async (achievement, index) => {
      if (index > 0) {
        await delay(550 * index);
      }
      const $achievement = $(this._render(achievement, event))
        .addClass('appearing')
        .appendTo(this._$container())
        .on('click', '.b-close', async () => {
          $achievement.addClass('removing');
          await delay(1000);
          $achievement.remove();
        });

      await delay();
      $achievement.removeClass('appearing');
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
