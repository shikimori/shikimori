pageLoad('profiles_ignored_users', 'profiles_ignored_topics', () => {
  $('.b-editable_grid .actions .b-js-link')
    .on('ajax:before', ({ currentTarget }) => {
      $(currentTarget).hide();
      $('<div class="ajax-loading vk-like"></div>').insertAfter(currentTarget);
    })
    .on('ajax:success', ({ currentTarget }) => {
      $(currentTarget).closest('tr').remove();
    });

  $('.user_ids').completableVariant();

  if ($('.user_ids').is(':appeared')) {
    $('.user_ids').focus();
  }

  $('.user_ids').on('keydown', e => {
    if ((e.keyCode === 10) || (e.keyCode === 13)) {
      e.preventDefault();
      $('.b-form').submit();
    }
  });
});
