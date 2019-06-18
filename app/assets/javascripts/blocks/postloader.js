import axios from 'helpers/axios';

$(() => {
  $.appear('.b-postloader');
});

// dynamic load of content for scrolled page
$(document).on('click appear', '.b-postloader', async ({ currentTarget, type }) => {
  const $postloader = $(currentTarget);
  if ($postloader.data('locked') ||
    (type === 'appear' && $postloader.data('ignore-appear'))
  ) {
    return;
  }

  const loading = I18n.t('frontend.lib.postloader.loading');
  const url = $postloader.data('remote');
  const filter = $postloader.data('filter');

  $postloader
    .html(`<div class="ajax-loading vk-like" title="${loading}..." />`)
    .data({ locked: true });

  const { data } = await axios.get(url);
  const $data = $('<div>').append(`${data.content}${data.postloader}`);

  if (filter) {
    filterPresentEntries($data, $postloader.parent(), filter);
  }

  $postloader.trigger('postloader:before', [$data, data]);
  $data.process(data.JS_EXPORTS);

  const $insertContent = $data.children();
  $postloader.replaceWith($insertContent);
  $insertContent.first().trigger('postloader:success');

  $postloader.data({ locked: false });
});

function filterPresentEntries($newEntries, $root, filter) {
  const presentIds = $(`.${filter}`, $root)
    .toArray()
    .map(v => v.id)
    .filter(v => v);

  const excludeSelector = presentIds
    .map(id => `.${filter}#${id}`)
    .join(',');

  $newEntries.children().filter(excludeSelector).remove();
}
