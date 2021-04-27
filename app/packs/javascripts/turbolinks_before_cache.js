import DynamicParser from 'dynamic_elements/_parser';

$(document).on('turbolinks:before-cache', () => {
  // need to reset style of HTML because it can be set to 'overflow: hidden' by magnificPopup
  $('html').attr('style', null);

  // need to remove old tooltips
  $('.tipsy').remove();
  $('body > .tooltip').remove();

  $('[data-dynamic]').addClass(DynamicParser.PENDING_CLASS);

  const jsExportKeys = $(document.body).data('js_export_supervisor_keys');
  if (!Object.isEmpty(jsExportKeys)) {
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

  $('.b-shiki_editor').addClass('unprocessed');

  // height shortener
  $('.b-height_shortener').each((_index, node) => {
    $(node).prev()
      .removeClass('shortened')
      .css('height', '');
    $(node).remove();
  });
});

function dumpJsExports(keys) {
  const jsExports = {};

  keys.forEach(plural => {
    const singular = plural.singularize();

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
