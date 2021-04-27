pageLoad('contests_edit', () => {
  $('.edit .proposing .hidden').removeClass('hidden');

  // удаление элемента из опроса
  $('form').on('click', 'input[type=checkbox]', () => updateMembersCount());

  $('form .proposing .take').on('click', ({ currentTarget }) => {
    $(currentTarget).parent().hide();

    $('.member-suggest').trigger(
      'autocomplete:success',
      [{ id: $(currentTarget).data('id'), name: $(currentTarget).data('text') }]
    );
    $('.member-suggest').trigger('blur');
  });

  $('.member-suggest')
    .completableVariant()
    .on('autocomplete:success', (_e, _entry) => updateMembersCount());

  updateMembersCount();
});

// пересчёт числа аниме
function updateMembersCount() {
  const membersCount = $('#contest_member_ids_').next().find('input:checked').length;

  $('.members_count').html(
    I18n.t('frontend.pages.p_contests.candidate', { count: membersCount })
  );
}
