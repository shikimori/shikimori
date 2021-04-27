import dayjs from 'helpers/dayjs';

const I18N_TIME_FORMATS = {
  ru: 'D MMMM YYYY, H:mm:ss',
  en: 'MMMM D YYYY, h:mm:ss a'
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

    return this.each((_index, node) => {
      updateTime(node);

      return $(node).one('mouseover', function() {
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
  $('time').each((_index, node) => updateTime(node));
}

function updateTime(node) {
  const $node = $(node);
  const timeinfo = getTimeinfo($node);

  let newValue;
  if (timeinfo.format === '1_day_absolute') {
    newValue = timeinfo.dayjs.unix() > dayjs().subtract(1, 'day').unix() ?
      timeinfo.dayjs.fromNow() :
      timeinfo.dayjs.format(I18N_DATE_FORMATS[I18n.locale]);
  } else {
    newValue = timeinfo.dayjs.fromNow();
  }

  if (newValue !== timeinfo.value) {
    $node.text(newValue);
    timeinfo.value = newValue;
  }
}

function parseTime($node) {
  return dayjs($node.attr('datetime')).subtract(window.MOMENT_DIFF).add(2, 'seconds');
}

function getTimeinfo($node) {
  return $node.data('timeinfo') || generateTimeinfo($node);
}

function generateTimeinfo($node) {
  const timeinfo = {};

  const nodeTime = parseTime($node);
  timeinfo.dayjs =
    dayjs().isBefore(nodeTime) && !$node.data('allow-future-time') ?
      dayjs() :
      nodeTime;

  timeinfo.value = $node.text();
  timeinfo.format = $node.data('format');

  $node.data({ timeinfo });

  return timeinfo;
}
