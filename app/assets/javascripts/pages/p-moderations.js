import URI from 'urijs';
import Turbolinks from 'turbolinks';
import cookies from 'js-cookie';

import { initArrayFieldApp } from './p-db_entries/edit_field';

import CollectionSearch from 'views/search/collection';
import { DatePicker } from 'views/application/date_picker';
import { animatedCollapse } from 'helpers/animated';

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

pageLoad('.moderations-index', () => {
  $('.b-brief').checkHeight({ max_height: 150 });

  $('.expand-all').on('click', function () {
    $(this).parent().next().next()
      .find('.collapsed.spoiler:visible')
      .click();
    $(this).remove();
  });

  $('.l-page')
    .on('ajax:before', '.b-log_entry .link.destroy', async ({ currentTarget }) => {
      $(currentTarget)
        .closest('.b-log_entry')
        .addClass('b-ajax');
    })
    .on('ajax:success', '.b-log_entry .link.destroy', async ({ currentTarget }) => {
      const $root = $(currentTarget).closest('.b-log_entry');
      await animatedCollapse($root[0]);
      $root.remove();
    })
    .on('ajax:complete', '.b-log_entry .link.destroy', async ({ currentTarget }) => {
      $(currentTarget)
        .closest('.b-log_entry')
        .removeClass('b-ajax');
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
