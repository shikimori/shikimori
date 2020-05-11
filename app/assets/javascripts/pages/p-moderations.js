import URI from 'urijs';
import Turbolinks from 'turbolinks';
import cookies from 'js-cookie';

import CollectionSearch from 'views/search/collection';
import { DatePicker } from 'views/application/date_picker';
import axios from 'helpers/axios';

import { initArrayFieldApp } from './p-db_entries/edit_field';

function datePicker() {
  if (!$('.date-filter').exists()) { return; }

  new DatePicker('.date-filter')
    .on('date:picked', function () {
      const newUrl = new URI(window.location.href).setQuery('created_on', this.value).href();
      Turbolinks.visit(newUrl);
    });
}

pageLoad('moderations_show', () => {
  const $form = $('form#sync');

  if (cookies.get('sync_type')) {
    $form.find('select').val(cookies.get('sync_type'));
  }

  $form.find('select').on('change', ({ currentTarget }) => (
    cookies.set('sync_type', currentTarget.value, { expires: 1, path: '/' })
  ));

  $form.find('input,select')
    .on('change keyup paste', () => {
      const type = $('form#sync select').val();
      const id = $('form#sync input[type=text]').val();

      $form.prop(
        'action',
        $form.data('url_template').replace('anime', type).replace('persons', 'people')
      );
      $form.find('input[type=submit]').prop('disabled', !id);
    })
    .trigger('change');
});

pageLoad('versions_index', 'users_index', datePicker);

pageLoad('versions_show', 'user_rate_logs_show', () => {
  $('.collapsed.spoiler', '.b-log_entry, .b-user_rate_log').click();
});

pageLoad(
  'bans_index',
  'abuse_requests_index',
  'versions_index',
  'review_index',
  () => {
    $('.b-brief').checkHeight({ max_height: 150 });

    $('.expand-all').on('click', function () {
      $(this).parent().next().next()
        .find('.collapsed.spoiler:visible')
        .click();
      $(this).remove();
    });
  });

pageLoad('roles_show', () => {
  new CollectionSearch('.b-collection_search');

  $('.l-page')
    .on('ajax:before', '.b-user', ({ currentTarget }) => {
      $(`.b-user[id=${currentTarget.id}]`).addClass('b-ajax');
    })
    .on('ajax:success', '.b-user', ({ currentTarget }, { content }) => {
      $(`.b-user[id=${currentTarget.id}]`).replaceWith(content);
    });
});

// users#index matches this too
pageLoad('users_index', () => {
  if ($('.b-collection_search').length) {
    new CollectionSearch('.b-collection_search');
  }
});

pageLoad('studios_edit', 'publishers_edit', () => {
  initArrayFieldApp();
});
