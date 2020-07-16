import moment from 'moment';

const I18N_TIME_FORMATS = {
  ru: 'D MMMM YYYY, H:mm:ss',
  en: 'MMMM Do YYYY, h:mm:ss a'
};

const I18N_DATE_FORMATS = {
  ru: 'll',
  en: 'll'
};

let initialized = false;
const refreshInterval = 60000;

$.fn.extend({
  livetime() {
    if (!initialized) {
      setInterval(updateTimes, refreshInterval);
      initialized = true;
    }

    return this.each(function () {
      updateTime(this);

      return $(this).one('mouseover', function () {
        const time = parseTime($(this));
        const format = I18N_TIME_FORMATS[I18n.locale];

        if (!$(this).data('no-tooltip')) {
          $(this).attr({ title: time.format(format) });
        }
      });
    });
  }
});

function updateTimes() {
  $('time').each(function () { return updateTime(this); });
}

function updateTime(node) {
  const $node = $(node);
  const timeinfo = getTimeinfo($node);

  let newValue;
  if (timeinfo.format === '1_day_absolute') {
    newValue = timeinfo.moment.unix() > moment().subtract(1, 'day').unix() ?
      timeinfo.moment.fromNow() :
      timeinfo.moment.format(I18N_DATE_FORMATS[I18n.locale]);
  } else {
    newValue = timeinfo.moment.fromNow();
  }

  if (newValue !== timeinfo.value) {
    $node.text(newValue);
    timeinfo.value = newValue;
  }
}

function parseTime($node) {
  return moment($node.attr('datetime')).subtract(window.MOMENT_DIFF).add(2, 'seconds');
}

function getTimeinfo($node) {
  return $node.data('timeinfo') || generateTimeinfo($node);
}

function generateTimeinfo($node) {
  const timeinfo = {};

  const nodeTime = parseTime($node);
  timeinfo.moment =
    moment().isBefore(nodeTime) && !$node.data('allow-future-time') ?
      moment() :
      nodeTime;

  timeinfo.value = $node.text();
  timeinfo.format = $node.data('format');

  $node.data({ timeinfo });

  return timeinfo;
}
