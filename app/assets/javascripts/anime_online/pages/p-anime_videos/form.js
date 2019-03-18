import axios from 'helpers/axios';

pageLoad(
  'anime_videos_new',
  'anime_videos_edit',
  'anime_videos_create',
  'anime_videos_update',
  () => {
    const $form = $('form');

    $form.on('submit', e => {
      if ($form.data('blocked')) {
        e.preventDefault();
      } else {
        $form.data({ blocked: true });
      }
    });

    const $videoUrl = $('#anime_video_url');
    const $episode = $('#anime_video_episode');
    const $videoPreview = $('.video-preview');

    if ($videoPreview.data('player_html')) {
      previewVideo($videoPreview.data('player_html'));
    }

    if ($episode.val() === '') {
      $episode.focus();
    } else {
      $videoUrl.focus();
    }

    $('.do-preview').on('click', async ({ currentTarget }) => {
      const videoUrl = $('#anime_video_url').val();

      $('.anime_video_url .error').remove();
      if (!videoUrl) {
        $('.anime_video_url').append('<div class="error">не может быть пустым</div>');
        $('#anime_video_url').focus();
        return;
      }

      $form.addClass('b-ajax');
      $('.video-preview').removeClass('hidden');

      const { data } = await axios
        .post($(currentTarget).data('href'), { url: videoUrl })
        .catch(() => ({ data: null }));

      $form.removeClass('b-ajax');
      previewVideo(data ? data.player_html : null);
    });

    $('.continue').on('click', () =>
      $('#continue').val('true')
    );

    $('#anime_video_author_name')
      .completable()
      .on('autocomplete:success autocomplete:text', function (e, result) {
        this.value = (result != null ? result.value : undefined) || result;
      });
  }
);

function previewVideo(html) {
  $('.video-preview')
    .show()
    .html(html);
  $('.create-buttons').show();

  $('.create-buttons .b-errors').toggle(!html);
  $('.create-buttons .buttons').toggle(!!html);
}
