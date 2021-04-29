import delay from 'delay';

import { loadImages } from '@/helpers/load_image';

pageLoad('dashboards_show', async () => {
  if ($('.p-dashboards-show .v2').length) { return; }

  $('.l-page').on('click', '.user_list .switch', ({ currentTarget }) => {
    $(currentTarget)
      .closest('.list-type')
      .toggleClass('hidden')
      .siblings('.list-type')
      .toggleClass('hidden');
  });

  await delay(500);
  loadImages('.cc-news').then(() => {
    const $userNews = $('.c-news_topics');
    const $generatedNews = $('.c-generated_news');

    alignBlocks($userNews, $generatedNews);
  });

  await delay(500);
  const $node = $('.y-sponsored');

  if ($node.children().length) {
    $node.addClass('block');
  }
});

function alignBlocks($userNews, $generatedNews) {
  const $topics = $generatedNews.find('.b-topic');
  const height = $userNews.outerHeight();

  if ($topics.length && (height < $generatedNews.outerHeight())) {
    $topics.last().remove();
    alignBlocks($userNews, $generatedNews);
  }
}
