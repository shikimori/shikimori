import isEmpty from 'lodash/isEmpty';

import DynamicParser from '@/dynamic_elements/_parser';

$(document).on('turbolinks:before-cache', () => {
  // need to reset style of HTML because it can be set to 'overflow: hidden' by magnificPopup
  $('html').attr('style', null);

  // need to remove old tooltips
  $('.tipsy').remove();
  $('body > .tooltip').remove();

  $('[data-dynamic]')
    .each((_index, node) => {
      const view = $(node).view();

      if (view && view.destroy) {
        view.destroy();
      }
    })
    .addClass(DynamicParser.PENDING_CLASS);

  const jsExportKeys = $(document.body).data('js_export_supervisor_keys');
  if (!isEmpty(jsExportKeys)) {
    dumpJsExports(jsExportKeys);
  }

  // TODO: remove after moving processCurrentDom logic into DynamicParser
  $('.b-video, .b-tooltipped, .b-spoiler, .b-image, .b-show_more')
    .addClass('unprocessed');
  $('.anime-tooltip-processed')
    .removeClass('anime-tooltip-processed')
    .addClass('anime-tooltip');
  $('.bubbled-processed')
    .removeClass('bubbled-processed')
    .addClass('bubbled');

  // height shortener
  $('.b-height_shortener').each((_index, node) => {
    $(node).prev()
      .removeClass('b-height_shortened')
      .css('height', '');
    $(node).remove();
  });
});

function dumpJsExports(keys) {
  const jsExports = {};

  keys.forEach(plural => {
    const singular = simpleSingularize(plural);

    $(`[data-track_${singular}]`).each((_index, node) => {
      const $node = $(node);
      const model = ($node.view() && $node.view().model) || $(node).data('model');

      if (!model) { return; }

      if (singular === 'user_rate') {
        const type = $(node).data(`track_${singular}`).split(':')[0];

        if (!model.id) { return; } // because there is default placeholder w/o id
        if (!jsExports[plural]) {
          jsExports[plural] = {};
        }
        if (!jsExports[plural][type]) {
          jsExports[plural][type] = [];
        }

        jsExports[plural][type].push(model);
      } else {
        if (!jsExports[plural]) {
          jsExports[plural] = [];
        }

        jsExports[plural].push(model);
      }
    });
  });

  $('script#js_export').html(`window.JS_EXPORTS = ${JSON.stringify(jsExports)};`);
}

function simpleSingularize(word) {
  if (word.endsWith('ies')) {
    return word.slice(0, -3) + 'y';
  } else if (word.endsWith('tes')) {
    // Handles cases like "rates" -> "rate"
    return word.slice(0, -1);
  } else if (word.endsWith('es')) {
    // Handles cases like "boxes" -> "box"
    return word.slice(0, -2);
  } else if (word.endsWith('s')) {
    // Removes the ending 's' for simple plural forms like "cars" -> "car"
    return word.slice(0, -1);
  }
  return word; // Return the original word if no rules apply
}
