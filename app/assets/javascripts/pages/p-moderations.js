import URI from 'urijs';
import Turbolinks from 'turbolinks';

import DatePicker from 'views/application/date_picker';
import axios from 'helpers/axios';

function datePicker() {
  if (!$('.date-filter').exists()) { return; }

  const picker = new DatePicker('.date-filter');

  picker.on('date:picked', function () {
    const newUrl = new URI(window.location.href).setQuery('created_on', this.value).href();
    Turbolinks.visit(newUrl);
  });
}

// раскрытие информации о загрузке видео
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


// страница модерации правок
page_load('versions_index', 'users_index', datePicker);

// страницы модерации
page_load(
  'bans_index',
  'abuse_requests_index',
  'versions_index',
  'review_index',
  'anime_video_reports_index',
  () => {
    // сокращение высоты инструкции
    $('.b-brief').checkHeight({ max_height: 150 });

    $('.expand-all').on('click', function () {
      $(this).parent().next().next()
        .find('.collapsed.spoiler:visible')
        .click();
      $(this).remove();
    });
  });

// информация о пропущенных видео
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
