import delay from 'delay';

import View from 'views/application/view';
import { ANIME_TOOLTIP_OPTIONS } from 'helpers/tooltip_options';
import axios from 'helpers/axios';

const NO_DATA_I18N_KEY = 'frontend.pages.p_animes.no_data';

export default class AnimesMenu extends View {
  async initialize() {
    this._scoresStatsBar();
    this._statusesStatsBar();

    // delay is required becase span.person-tooltip
    // is replaced by a.person-tooltip because of linkeable class
    await delay(100);
    this._history();
  }

  get isHistoryAllowed() {
    return window.SHIKI_USER.isSignedIn && window.SHIKI_USER.isYearRegistered;
  }

  get $historyBlock() {
    return this.$('.history');
  }

  _scoresStatsBar() {
    this.$('#rates_scores_stats').empty().bar({
      filter(entry, percent) { return percent >= 2; },
      no_data($chart) {
        $chart.html(`<p class='b-nothing_here'>${I18n.t(NO_DATA_I18N_KEY)}</p>`);
      }
    });
  }

  _statusesStatsBar() {
    this.$('#rates_statuses_stats').empty().bar({
      title(entry, percent) {
        return percent > 15 ? entry.value : '';
      },
      no_data($chart) {
        $chart.html(`<p class='b-nothing_here'>${I18n.t(NO_DATA_I18N_KEY)}</p>`);
      }
    });
  }

  _history() {
    const sourceUrl = this.$historyBlock.attr('data-source_url');
    if (!sourceUrl) { return; }

    this.$historyBlock.one('mouseover', async () => {
      const { data } = await axios.get(sourceUrl);
      this._tooltipContent(data);
    });

    $('.person-tooltip', this.$historyBlock).tooltip(
      Object.add(ANIME_TOOLTIP_OPTIONS, {
        position: 'top right',
        offset: [-28, 59],
        relative: true,
        place_to_left: true,
        predelay: 100,
        delay: 100,
        effect: 'toggle'
      })
    );
  }

  _tooltipContent(data) {
    Object.forEach(data, (entry, id) => {
      const $tooltip = $('.tooltip-details', `#history-entry-${id}-tooltip`);
      if (!$tooltip.length) { return; }

      if (entry.length) {
        $tooltip.html(
          entry.map(v => `<a class='b-link' href="${v.link}">${v.title}</a>`).join('')
        );
      } else {
        $(`#history-entry-${id}-tooltip`).children().remove();
      }
    });
  }
}
