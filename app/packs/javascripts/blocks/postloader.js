import axios from '@/utils/axios';
import I18n from '@/utils/i18n';

$(() => {
  $.appear('.b-postloader');
});

// dynamic load of content for scrolled page
$(document).on('click appear', '.b-postloader', async ({ currentTarget, type }) => {
  let $postloader = $(currentTarget);
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
  const $data = $('<div>').append(data.content);

  if (filter) {
    filterPresentEntries($data, $postloader.parent(), filter);
  }

  $postloader.trigger('postloader:before', [$data, data]);

  const $newPostloader = data.postloader ?
    $(data.postloader) :
    $data.find('.b-postloader');

  if ($newPostloader.length) {
    $newPostloader.attr('data-page', page);
    $newPostloader.attr('data-pages_limit', $postloader.data('pages_limit'));
    $newPostloader.attr('data-insert_into', $postloader.data('insert_into'));

    if (page >= ($newPostloader.data('pages_limit') || 100)) {
      $newPostloader.attr('data-locked', true);

      const pagesLimit = $newPostloader.data('pages_limit');
      const $prevLink = $newPostloader.find('a.prev');
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
  }

  if (data.postloader) {
    $postloader.replaceWith($newPostloader);
    $postloader = $newPostloader;
  }

  const $insertContent = $data.children();

  (
    $postloader.data('insert_into') ?
      $($postloader.data('insert_into')).append($insertContent) :
      $insertContent.insertBefore($postloader)
  )
    .process(data.JS_EXPORTS); // .process must be called after new content is inserted into DOM

  $postloader.trigger('postloader:success');

  if (!data.postloader) {
    $postloader.remove();
  }

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
