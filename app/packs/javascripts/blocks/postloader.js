import axios from '@/helpers/axios';

$(() => {
  $.appear('.b-postloader');
});

// dynamic load of content for scrolled page
$(document).on('click appear', '.b-postloader', async ({ currentTarget, type }) => {
  const $postloader = $(currentTarget);
  const page = ($postloader.data('page') || 1) + 1;

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
  // $data.process(data.JS_EXPORTS);
  const $dataPostloader = $data.find('.b-postloader');
  $dataPostloader.attr('data-page', page);

  if (page >= ($dataPostloader.data('pages_limit') || 100)) {
    $dataPostloader.attr('data-locked', true);

    const pagesLimit = $dataPostloader.data('pages_limit');
    const $prevLink = $dataPostloader.find('a.prev');
    const prevUrl = $prevLink.attr('href');
    const match = prevUrl.match(/(?:\?|&|\/)page(?:=|\/)(\d+)/);

    if (match) {
      const currentPage = parseInt(match[1]) + 1;
      const newPrevPage = currentPage - pagesLimit * 2 + 1;

      if (newPrevPage < 0) {
        $prevLink.remove();
      } else {
        const newPrevUrl = prevUrl
          .replace(/(\?|&|\/)page(=|\/)(\d+)/, `$1page$2${newPrevPage}`)
          .replace(/&page=1$/, '')
          .replace('?page=1&', '?')
          .replace(/\?page=1$/, '')
          .replace(/\/page\/1/, '')
          .replace(/\/$/, '');

        $prevLink.attr('href', newPrevUrl);
      }
    }
  }

  const $insertContent = $data.children();

  $postloader.replaceWith($insertContent);
  $insertContent
    .process(data.JS_EXPORTS) // .process must be called after new content is inserted into DOM
    .first()
    .trigger('postloader:success');

  // no need to set `locked: false` becaise $postloader is replaced by new content
  // $postloader.data({ locked: false });
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
