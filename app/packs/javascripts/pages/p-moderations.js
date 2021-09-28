import TinyUri from 'tiny-uri';
import Turbolinks from 'turbolinks';
import cookies from 'js-cookie';
import delay from 'delay';

import { initArrayFieldApp } from './p-db_entries/edit_field';

import CollectionSearch from '@/views/search/collection';

import checkHeight from '@/helpers/check_height';
import { DatePicker } from '@/views/application/date_picker';
import { animatedCollapse } from '@/helpers/animated';

function datePicker() {
  if (!$('.date-filter').exists()) { return; }

  new DatePicker('.date-filter')
    .on('date:picked', function () {
      const newUrl = new TinyUri(window.location.href)
        .query.set('created_on', this.value || null)
        .toString();
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

pageLoad('versions_show', 'user_rate_logs_show', async () => {
  await delay(); // need log entries to be processed first
  $('.collapsed.spoiler', '.b-log_entry, .b-user_rate_log').click();
});

pageLoad('.moderations-index', () => {
  checkHeight($('.b-brief'), { maxHeight: 150 });

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

  const $form = $('form#versions_form').removeClass('b-ajax');
  if (!$form.length) { return; }

  ['user_id', 'moderator_id'].forEach(type => {
    const $input = $(`#version_${type}`);
    const $suggest = $(`.${type}-suggest`);
    const $placeholder = $suggest.parent().find('.placeholder');

    $suggest
      .completable({ minChars: 1 })
      .on('autocomplete:success', (_e, { id, name, url }) => {
        $input.val(id);
        $suggest.addClass('hidden');

        $placeholder.removeClass('hidden');
        $placeholder.find('.nickname').html(`<a href="${url}">${name}</a>`);

        $form.addClass('b-ajax').submit();
      });

    $placeholder.find('.b-js-action.remove').on('click', () => {
      $input.val('');
      $placeholder.addClass('hidden');
      $suggest.removeClass('hidden').val('');

      $form.addClass('b-ajax').submit();
    });
  });

  $('#version_field').on('change', ({ currentTarget }) => {
    const itemType = currentTarget.selectedOptions[0].getAttribute('data-item_type');
    $('#version_item_type').val(itemType);

    $form.addClass('b-ajax').submit();
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
