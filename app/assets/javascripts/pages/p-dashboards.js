import getjs from 'get-js';
import delay from 'delay';

page_load('dashboards_show', () => {
  $('.user_list .switch').on('click', function () {
    return $(this)
      .closest('.list-type')
      .toggleClass('hidden')
      .siblings('.list-type')
      .toggleClass('hidden');
  });

  delay(500).then(() =>
    $('.cc-news').imagesLoaded(() => {
      const $userNews = $('.c-news_topics');
      const $generatedNews = $('.c-generated_news');

      alignBlocks($userNews, $generatedNews);
    })
  );

  delay(1000).then(() => {
    if ('VK' in window) {
      vkWidget();
    }
    getjs('//vk.com/js/api/openapi.js?146').then(vkWidget);
  });

  delay(1500).then(() => {
    const $node = $('.y-sponsored');

    if ($node.children().length) {
      $node.addClass('block');
    }
  });
});

function alignBlocks($userNews, $generatedNews) {
  const $topics = $generatedNews.find('.b-topic');
  const height = $userNews.outerHeight();

  if ($topics.length && (height < $generatedNews.outerHeight())) {
    $topics.last().remove();
    alignBlocks($userNews, $generatedNews);
  }
}

function vkWidget() {
  const $node = $('#vk_groups').addClass('block');

  window.VK.Widgets.Group(
    'vk_groups',
    {
      mode: 4,
      width: $node.width(),
      height: '500'
    },
    9273458
  );
}
