import delay from 'delay';
import Turbolinks from 'turbolinks';

import ajaxCacher from 'services/ajax_cacher';
import inNewTab from 'helpers/in_new_tab';
import axios from 'helpers/axios';

pageLoad('recommendations_index', 'recommendations_favourites', async () => {
  // если страница ещё не готова, перегрузимся через 5 секунд
  if ($('p.pending').exists()) {
    const url = document.location.href;
    await delay(5000);

    if (url === document.location.href) {
      window.location.reload();
      return;
    }
  }

  $('body').on('mouseover', '.b-catalog_entry', ({ currentTarget }) => {
    const $node = $(currentTarget);

    if (!window.SHIKI_USER.isSignedIn) { return; }
    if ($node.hasClass('entry-ignored')) { return; }

    if ($node.data('ignore_augmented')) {
      $node.data('ignore_button').show();
      return;
    }

    const title = I18n.t('frontend.pages.p_recommendations_index.dont_recommend_franchise');
    const $button = $(
      `<span class='controls'>
        <span class='delete mark-ignored' title='${title}'></span>
      </span>`
    ).appendTo($node.find('.image-cutter'));

    $node.data({
      ignore_augmented: true,
      ignore_button: $button
    });
  });

  $('body').on('mouseout', '.b-catalog_entry', ({ currentTarget }) => {
    const $button = $(currentTarget).data('ignore_button');
    if ($button) {
      $button.hide();
    }
  });

  $('body').on('click', '.entry-ignored', e => {
    if (!inNewTab(e)) {
      e.preventDefault();
    }
  });

  $('body').on('click', '.b-catalog_entry .mark-ignored', async e => {
    e.preventDefault();

    const $node = $(e.currentTarget).closest('.b-catalog_entry');
    const $link = $node.find('a').first();

    if ($link.attr('href').match(/(anime|manga)s\//)) {
      const targetType = RegExp.$1;
      const targetId = $node.prop('id');

      $node.addClass('entry-ignored');
      $(e.currentTarget).hide();
      ajaxCacher.reset();

      const { data } = await axios.post(
        '/recommendation_ignores',
        { target_type: targetType, target_id: targetId }
      );
      const selector = data.map(v => `.entry-${v}`).join(',');
      $(selector).addClass('entry-ignored');
    }
  });
});
