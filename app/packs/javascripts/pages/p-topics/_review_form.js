import delay from 'delay';

pageLoad('topics_new', () => {
  const $form = $('.new-review-form');
  if (!$form.length) { return; }

  const $topicLinked = $('#topic_linked', $form);
  const $linkedId = $('#topic_linked_id', $form);
  const $linkedType = $('#topic_linked_type', $form);

  const $link = $('.b-link_button', $form);

  $('.topic-linked .remove', $form).on('click', () => (
    $link
      .removeAttr('href')
      .addClass('disabled')
  ));

  $topicLinked.on('autocomplete:success', async () => {
    await delay(); // must be sure that handler from p-topics/_form.js was triggered first

    $link
      .attr(
        'href',
        $link.data('url_template')
          .replace('/animes/', `/${$linkedType.val().toLowerCase()}s/`)
          .replace('ranobes', 'ranobe')
          .replace(/TARGET_ID/g, $linkedId.val())
          .replace(/TARGET_TYPE/g, $linkedType.val())
      )
      .removeClass('disabled');
  });
});
