import axios from 'helpers/axios';
import Wall from 'views/wall/view';

pageLoad('topics_new', 'topics_edit', 'topics_create', 'topics_update', () => {
  const $form = $('.b-form.edit_topic, .b-form.new_topic');
  const $linkedId = $('#topic_linked_id', $form);
  const $linkedType = $('#topic_linked_type', $form);

  // poster upload
  const $upload = $('.topic-posters .b-dropzone', $form);
  const $wall = $upload.find('.b-shiki_wall');

  $upload
    .shikiFile({
      progress: $upload.find('.b-upload_progress'),
      input: $upload.find('input[type=file]')
    })
    .on('upload:success', (_e, data) => {
      const $image = $(
        `<a href='${data.url}' rel='new-wall' class='b-image b-link' \
id='${data.id}'>\
<img src='${data.preview}' class=''> \
<div class='mobile-edit'></div><div class='controls'> \
<div class='delete'></div>\
<div class='confirm'></div>\
<div class='cancel'></div></div></a>`
      ).appendTo($wall);

      $('.confirm', $image).on('click', e => {
        e.preventDefault();
        removeImage($image, $wall);
      });

      resetWall($wall);
    });

  $('.b-image .confirm', $upload).on('click', e => {
    e.preventDefault();
    removeImage($(e.target).closest('.b-image').remove(), $wall);
  });

  // attach video
  const $topicVideo = $('.topic-video', $form);

  if ($topicVideo.data('video_id')) {
    attachVideo({
      video_id: $topicVideo.data('video_id'),
      content: $topicVideo.data('content')
    }, $topicVideo, $wall);
  }

  const $topicVideoForm = $('.form', $topicVideo);
  const $attach = $('.attach', $topicVideoForm);

  $attach.on('click', () => {
    const animeId = linkedAnimeId($linkedType, $linkedId);
    const url = $attach.data('url').replace('ANIME_ID', animeId || 0);
    const form = {
      video: {
        anime_id: animeId,
        url: $('#topic_video_url', $topicVideoForm).val(),
        kind: $('#topic_video_kind', $topicVideoForm).val(),
        name: $('#topic_video_name', $topicVideoForm).val()
      }
    };

    $topicVideo.addClass('b-ajax');

    axios
      .post(url, form)
      .then(data => attachVideo(data.data, $topicVideo, $wall));
  });

  // create/edit a topic
  $form.on('submit', () => {
    const $attachments = $('.attachments-hidden', $form).empty();

    // posters
    $('.b-dropzone a', $form)
      .map((_index, node) => $(node).attr('id'))
      .each((_index, id) =>
        $attachments.append(
          `<input type='hidden' name='topic[wall_ids][]' value="${id}" />`
        )
      );

    // video
    const videoId = $topicVideo.data('video_id');
    if (videoId) {
      $attachments.append(
        `<input type='hidden' name='topic[video_id]' value="${videoId}" />`
      );
    }
  });

  if ($('#topic_tags').length) {
    initTagsApp();
  }
});

function removeImage($image, $wall) {
  $image.remove();
  resetWall($wall);
}

function resetWall($wall) {
  $wall.find('img').css({ width: '', height: '' });
  new Wall($wall);
}

function linkedAnimeId($linkedType, $linkedId) {
  return $linkedType.val() === 'Anime' ? $linkedId.val() : null;
}

function attachVideo(videoData, $topicVideo, $wall) {
  const $topicVideoForm = $('.form', $topicVideo);
  const $topicVideoRemove = $('.remove', $topicVideo);
  const $topicVideoErrors = $('.errors', $topicVideo);

  $topicVideo.removeClass('b-ajax');

  if (videoData.errors) {
    $topicVideoErrors.show().html(videoData.errors.join(', '));
    return;
  }
  $topicVideoErrors.hide();

  $topicVideo.data({ video_id: videoData.video_id });
  $topicVideoForm.hide();
  $topicVideoRemove.removeClass('hidden');

  const $video = $(videoData.content).prependTo($wall);
  resetWall($wall);

  $topicVideoRemove.one('click', e => {
    e.preventDefault();
    $topicVideo.data({ video_id: null });
    $topicVideoForm.show();
    $topicVideoRemove.addClass('hidden');

    removeImage($video, $wall);
  });
}

async function initTagsApp() {
  const { Vue } = await import(/* webpackChunkName: "vue" */ 'vue/instance');
  const { default: TagsInput } = await import('vue/components/tags_input');

  const $app = $('#vue_tags_input');
  const $tags = $('.b-input.topic_tags');
  $tags.hide();

  new Vue({
    el: '#vue_tags_input',
    render: h => h(TagsInput, {
      props: {
        label: $tags.find('label').text(),
        hint: $tags.find('.hint').html(),
        input: $tags.find('input')[0],
        value: $app.data('value'),
        autocompleteBasic: $app.data('autocomplete_basic'),
        autocompleteOther: $app.data('autocomplete_other'),
        tagsLimit: 3,
        isDowncase: true
      }
    })
  });
}
