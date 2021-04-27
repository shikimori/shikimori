pageLoad('profiles_video_uploads', () => {
  $('.l-page').on('click', '.b-log_entry.video .collapsed', function () {
    const $player = $(this).parent().find('.player');

    if ($player.data('html')) {
      $player
        .html($player.data('html'))
        .data({ html: '' });
    }
  });
});
