import axios from '@/utils/axios';

pageLoad('contests_show', 'contests_edit', () => {
  if (!$('.proposing').exists()) { return; }

  $('.proposing .suggestion .show').on('click', ({ currentTarget }) => {
    $voters(currentTarget).show();
    $hide(currentTarget).show();
    $show(currentTarget).hide();
  });

  $('.proposing .suggestion .hide').on('click', ({ currentTarget }) => {
    $voters(currentTarget).hide();
    $hide(currentTarget).hide();
    $show(currentTarget).show();
  });

  $('.proposing .suggestion .show.ajaxable').on('click', async ({ currentTarget }) => {
    if (!$(currentTarget).hasClass('ajaxable')) { return; }

    $(currentTarget).removeClass('ajaxable');
    const { data } = await axios.get($(currentTarget).data('href'));
    $(currentTarget).trigger('ajax:success', data);
  });

  $('.proposing .suggestion .show').on('ajax:success', ({ currentTarget }, html) => {
    $voters(currentTarget).html(html);
  });
});

pageLoad('contests_show', () => {
  if (!$('.proposing').exists()) { return; }

  const $suggest = $('.proposing .item-suggest');
  $suggest
    .completable()
    .on('autocomplete:success', ({ currentTarget }, entry) => {
      $(currentTarget).val(entry.name);
      $(currentTarget).parents('form').find('#contest_suggestion_item_id').val(entry.id);
      $(currentTarget).parents('form').submit();
    });

  $('.proposing form').on('submit', function (e) {
    if (Object.isEmpty($(this).find('#contest_suggestion_item_id').val())) {
      e.preventDefault();
    }
  });
});

function $voters(node) {
  return $(node)
    .parents('.suggestion')
    .find('.voters-container');
}

function $hide(node) {
  return $(node)
    .parents('.suggestion')
    .find('.hide');
}

function $show(node) {
  return $(node)
    .parents('.suggestion')
    .find('.show');
}
