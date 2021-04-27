pageLoad('.clubs', () => {
  const $menu = $('.b-clubs-menu');
  const $actionsBlock = $('.b-subposter-actions', $menu);
  const $inviteBlock = $menu.children('.invite');
  const $nicknameInput = $('#club_invite_dst_id', $inviteBlock);

  $('.invite', $actionsBlock).on('click', () => {
    $actionsBlock.hide();
    $inviteBlock.show();
    $nicknameInput.focus();
  });

  $('.cancel', $inviteBlock).on('click', () => {
    $actionsBlock.show();
    $inviteBlock.hide();
  });

  $('form', $inviteBlock).on('ajax:success', () => {
    $nicknameInput.val('');
    $('.cancel', $inviteBlock).click();
  });

  $nicknameInput
    .completable()
    .on('autocomplete:success autocomplete:text', (_e, entry) => {
      if (entry.constructor === Object && entry.name) {
        $nicknameInput.val(entry.name);
      }
      $nicknameInput.closest('form').submit();
    })
    .on('keydown', e => {
      if (e.keyCode === 27) { // esc
        $('.cancel', $inviteBlock).click();
      }
    });

  $('.upload input', $menu).on('change', ({ currentTarget }) => {
    $(currentTarget).closest('form').submit();
  });
});
