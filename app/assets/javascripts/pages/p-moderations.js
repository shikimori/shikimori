import URI from 'urijs';
import Turbolinks from 'turbolinks';

import CollectionSearch from 'views/application/collection_search';
import DatePicker from 'views/application/date_picker';
import axios from 'helpers/axios';

function datePicker() {
  if (!$('.date-filter').exists()) { return; }

  new DatePicker('.date-filter')
    .on('date:picked', function () {
      const newUrl = new URI(window.location.href).setQuery('created_on', this.value).href();
      Turbolinks.visit(newUrl);
    });
}

page_load('anime_video_reports_index', 'profiles_videos', () => {
  datePicker();

  $('.l-page').on('click', '.b-log_entry.video .collapsed', ({ currentTarget }) => {
    const $player = $(currentTarget).parent().find('.player');
    if (!$player.data('html')) { return; }

    $player
      .html($player.data('html'))
      .data({ html: '' });
  });
});

page_load('versions_index', 'users_index', datePicker);

page_load('versions_show', 'user_rate_logs_show', () => {
  $('.collapsed.spoiler', '.b-log_entry, .b-user_rate_log').click();
});

page_load(
  'bans_index',
  'abuse_requests_index',
  'versions_index',
  'review_index',
  'anime_video_reports_index',
  () => {
    $('.b-brief').checkHeight({ max_height: 150 });

    $('.expand-all').on('click', function () {
      $(this).parent().next().next()
        .find('.collapsed.spoiler:visible')
        .click();
      $(this).remove();
    });
  });

page_load('moderations_missing_videos', () => {
  $('.missing-video .show-details').one('click', async e => {
    e.preventDefault();

    const { data } = await axios.get($(e.currentTarget).data('episodes_url'));
    $(e.currentTarget).parent().find('.details').html(data);
  });

  $('.missing-video .show-details').on('click', e => {
    e.preventDefault();

    $(e.currentTarget).parent()
      .find('.details')
      .toggleClass('hidden');
  });
});

page_load('roles_show', () => {
  new CollectionSearch('.b-search');

  $('.l-page')
    .on('ajax:before', '.b-user', ({ currentTarget }) => {
      $(`.b-user[id=${currentTarget.id}]`).addClass('b-ajax');
    })
    .on('ajax:success', '.b-user', ({ currentTarget }, { content }) => {
      $(`.b-user[id=${currentTarget.id}]`).replaceWith(content);
    });
});
