import axios from '@/helpers/axios';
import Wall from '@/views/wall/view';

export function initForm(type, $form, $wall, $video) {
  $form.on('submit', () => {
    const $attachments = $('.attachments-submit-container', $form).empty();

    // posters
    $('.b-dropzone a', $form)
      .map((_index, node) => $(node).attr('id'))
      .each((_index, id) =>
        $attachments.append(
          `<input type='hidden' name='${type}[wall_ids][]' value="${id}" />`
        )
      );

    // video
    const videoId = $video.data('video_id');
    if (videoId) {
      $attachments.append(
        `<input type='hidden' name='${type}[video_id]' value="${videoId}" />`
      );
    }
  });
}

export async function initWall($form, $wall) {
  const { FileUploader } = await import('views/file_uploader');

  const $upload = $('.topic-posters .b-dropzone', $form);

  if (!$upload.length) { return; } // it can be page with terms

  new FileUploader($upload[0])
    .on('upload:file:success', (_e, { response }) => {
      const $image = $(
        `<a href='${response.url}' rel='new-wall' class='b-image b-link' \
id='${response.id}'>\
<img src='${response.preview}' class=''> \
<div class='mobile-edit'></div><div class='controls'> \
<div class='delete'></div>\
<div class='confirm'></div>\
<div class='cancel'></div></div></a>`
      ).appendTo($wall);

      $('.confirm', $image).on('click', e => {
        e.preventDefault();
        removeImage($image, $wall);
      });
    })
    .on('upload:complete', () => (
      resetWall($wall)
    ));

  $('.b-image .confirm', $upload).on('click', e => {
    e.preventDefault();
    removeImage($(e.target).closest('.b-image').remove(), $wall);
  });
}

function removeImage($image, $wall) {
  $image.remove();
  resetWall($wall);
}

function resetWall($wall) {
  $wall.find('img').css({ width: '', height: '' });
  new Wall($wall);
}

// function linkedAnimeId($linkedType, $linkedId) {
//   return $linkedType.val() === 'Anime' ? $linkedId.val() : null;
// }

export function initVideo(type, $form, $wall) {
  const $video = $('.topic-video', $form);
  // const $linkedId = $('#topic_linked_id', $form);
  // const $linkedType = $('#topic_linked_type', $form);

  if ($video.data('video_id')) {
    attachVideo({
      video_id: $video.data('video_id'),
      content: $video.data('content')
    }, $video, $wall);
  }

  const $videoForm = $('.form', $video);
  const $attach = $('.attach', $videoForm);

  $attach.on('click', () => {
    // const animeId = linkedAnimeId($linkedType, $linkedId);
    const url = $attach.data('url').replace('ANIME_ID', 0); // .replace('ANIME_ID', animeId || 0);

    const form = {
      video: {
        // anime_id: animeId,
        url: $(`#${type}_video_url`, $videoForm).val(),
        kind: $(`#${type}_video_kind`, $videoForm).val(),
        name: $(`#${type}_video_name`, $videoForm).val()
      }
    };

    $video.addClass('b-ajax');

    axios
      .post(url, form)
      .then(data => attachVideo(data.data, $video, $wall));
  });

  return $video;
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

export async function initTagsApp(type) {
  if (!$(`#${type}_tags`).length) { return; }

  const { Vue } = await import(/* webpackChunkName: "vue" */ 'vue/instance');
  const { default: TagsInput } = await import('vue/components/tags_input');

  const $app = $('#vue_tags_input');
  const $tags = $(`.b-input.${type}_tags`);
  const initialHtml = $app[0].outerHTML;

  $tags.hide();

  return new Vue({
    el: '#vue_tags_input',
    render: h => h(TagsInput, {
      props: {
        label: $tags.find('label').text(),
        hint: $tags.find('.hint').html(),
        input: $tags.find('input')[0],
        value: $app.data('value'),
        autocompleteBasic: $app.data('autocomplete_basic'),
        autocompleteOther: $app.data('autocomplete_other') || [],
        tagsLimit: 3,
        isDowncase: true
      }
    }),
    beforeDestroy() {
      $tags.show();
      $(this.$el).replaceWith(initialHtml);
    },
  });
}
