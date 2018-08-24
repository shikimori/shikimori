page_load(
  'anime_videos_new',
  'anime_videos_edit',
  'anime_videos_create',
  'anime_videos_update',
  () => {
    const $form = $('form');

    $form.on('submit', (e) => {
      if ($form.data('blocked')) {
        e.preventDefault()
      } else {
        $form.data({ blocked: true });
      }
    })


    const $video_url = $('#anime_video_url');
    const $episode = $('#anime_video_episode');
    const $video_preview = $('.video-preview');

    if ($video_preview.data('player_html')) {
      preview_video($video_preview.data('player_html'));
    }

    if ($episode.val() === '') {
      $episode.focus();
    } else {
      $video_url.focus();
    }

    // клик по "Проверить видео"
    $('.do-preview').on('click', function() {
      const video_url = $('#anime_video_url').val();

      $('.anime_video_url .error').remove();
      if (!video_url) {
        $('.anime_video_url').append('<div class="error">не может быть пустым</div>');
        $('#anime_video_url').focus();
        return;
      }

      $form.addClass('b-ajax');
      $('.video-preview').removeClass('hidden');

      $.ajax({
        url: $(this).data('href'),
        data: {
          url: video_url
        },
        type: 'POST',
        dataType: 'json',
        success(data, status, xhr) {
          $form.removeClass('b-ajax');
          preview_video(data.player_html);
        },
        error() {
          $form.removeClass('b-ajax');
          preview_video(null);
        }
      });
    });

    // клик по "Работает и загрузить ещё"
    $('.continue').on('click', () =>
      $('#continue').val('true')
    );

    $('#anime_video_author_name')
      .completable()
      .on('autocomplete:success autocomplete:text', function(e, result) {
        this.value = (result != null ? result.value : undefined) || result;
    });
  });

  var preview_video = function(player_html) {
    $('.video-preview')
      .show()
      .html(player_html);
    $('.create-buttons').show();

    $('.create-buttons .b-errors').toggle(!player_html);
    return $('.create-buttons .buttons').toggle(!!player_html);
  };
});
