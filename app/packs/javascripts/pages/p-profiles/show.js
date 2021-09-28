import axios from '@/utils/axios';
import dayjs from '@/utils/dayjs';

import { isMobile } from 'shiki-utils';

pageLoad('profiles_show', () => {
  $('.friend-action').on('ajax:success', () => (
    $('.friend-action').toggle()
  ));
  $('.ignore-action').on('ajax:success', () => (
    $('.ignore-action').toggle()
  ));

  $('h1.aliases').tipsy({
    gravity: isMobile() ? 'n' : 'w',
    html: true,
    prependTo: document.body,
    async title() {
      const { data } = await axios.get(this.getAttribute('data-tooltip_url'));
      return data;
    }
  });

  $('.activity .graph')
    .empty()
    .bar({
      before(stats, options, $chart) {
        stats.forEach((stat, _index) =>
          stat.dates = {
            from: new Date(stat.name[0] * 1000),
            to: new Date(stat.name[1] * 1000)
          }
        );

        options.interval = Math.round(dateDiff(stats[0].dates.from, stats[0].dates.to));
        options.range = Math.round(dateDiff(stats[0].dates.from, stats[stats.length - 1].dates.to));
        options.index_label = 0;

        if (options.y_axis) {
          $chart.addClass('y-axis');
          // transparent lines
          const html = [];
          let i = 1;

          while (i <= 10) {
            html.push(`<div class="ruler" style="top: ${i * 10}%;"></div>`);
            i += 1;
          }
          $chart.html(html.join(''));
        }
      },

      title(entry) {
        const hourWord = p(
          entry.value,
          I18n.t('frontend.pages.p_profiles.hour.one'),
          I18n.t('frontend.pages.p_profiles.hour.few'),
          I18n.t('frontend.pages.p_profiles.hour.many')
        );

        const dateFormat = window.LOCALE === 'en' ? 'MMMM D' : 'D MMMM';
        const fromDate = dayjs(entry.dates.from).format(dateFormat);
        const toDate = dayjs(entry.dates.to).format(dateFormat);

        if (fromDate === toDate) {
          return I18n.t('frontend.pages.p_profiles.label.short', {
            hours: entry.value,
            hourWord,
            date: fromDate
          });
        }
        const days = dateDiff(entry.dates.from, entry.dates.to);
        const dayWord = days === Math.round(days) ?
          p(entry.value,
            I18n.t('frontend.pages.p_profiles.day.one'),
            I18n.t('frontend.pages.p_profiles.day.few'),
            I18n.t('frontend.pages.p_profiles.day.many')) :
          I18n.t('frontend.pages.p_profiles.day.many');

        return I18n.t('frontend.pages.p_profiles.label.full', {
          hours: entry.value,
          hourWord,
          fromDate,
          toDate,
          days,
          dayWord
        });
      },

      xAxis(entry, index, stats, options) {
        let label;
        if (index < options.index_label) { return ''; }

        const { from, to } = entry.dates;
        const date = entry !== stats.last() ? from : to;

        if (index === 0) {
          options.index_label = 3;
          label = date.getFullYear();
        } else if (options.prior.dates.from.getFullYear() !== date.getFullYear()) {
          label = date.getFullYear();
          options.index_label = index + 3;
        } else if (options.prior.dates.from.getMonth() !== date.getMonth()) {
          label = dayjs(date).format('MMM').capitalize();
          options.index_label = index + 3;
        } else if (options.range <= 120) { // and entry.value > 0
          label = date.getDate();
          options.index_label = index + 2;
        }

        options.prior = entry;
        return label || '';
      },

      noData($chart) {
        $chart
          .html(`<p class="stat-sorry">${$chart.data('no_stat_text')}</p>`)
          .removeClass('bar')
          .attr('id', false);
      }
    });
});

function dateDiff(dateEarlier, dateLater) {
  const oneDay = 1000 * 60 * 60 * 24;
  return Math.round(((dateLater.getTime() - dateEarlier.getTime()) / oneDay) * 10) / 10;
}
