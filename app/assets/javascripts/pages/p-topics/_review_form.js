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
          .replace('TARGET_ID', $linkedId.val())
          .replace('TARGET_TYPE', $linkedType.val())
      )
      .removeClass('disabled');

    console.log($linkedId.val(), $linkedType.val());
  });

  // const $topicLinked = $('#topic_linked', $form);
  // const $topicLink = $('.topic-link', $form);
  //
  // const initialLinkedType = $('option', LINKED_TYPE_USER_SELECT).val();
  //
  // $(LINKED_TYPE_USER_SELECT)
  //   .on('change', ({ currentTarget }) => {
  //     const { value } = currentTarget;
  //     const loweredValue = value.toLowerCase();
  //
  //     $topicLinked
  //       .data('autocomplete', $topicLinked.data(`${loweredValue}-autocomplete`))
  //       .attr('placeholder', $topicLinked.data(`${loweredValue}-placeholder`))
  //       .trigger('flushCache');
  //   })
  //   .val(initialLinkedType)
  //   .trigger('change');
  //
  // $('.topic-linked .remove', $form).on('click', e => {
  //   e.preventDefault();
  //
  //   $topicLink.find('a').remove();
  //   $('#topic_linked_id', $form).val('');
  //   // $('#topic_linked_type', $form).val('');
  //   $('#topic_linked', $form).val('');
  //
  //   $topicLinked.show();
  //   $(LINKED_TYPE_USER_SELECT).show();
  //   $topicLink.hide();
  // });
  // $topicLinked.completable()
  //   .on('autocomplete:success', ({ currentTarget }, entry) => {
  //     console.log(currentTarget, entry);
  //     // const pluralLinkedType = `${$linkedType.val().toLowerCase()}s`.replace('ranobes', 'ranobe');
  //     //
  //     // currentTarget.value = '';
  //     //
  //     // $('#topic_linked_id', $form).val(entry.id);
  //     // $('#topic_linked_type', $form).val($linkedType.val());
  //     //
  //     // $topicLink.find('a').remove();
  //     // $topicLink.prepend(`
  //     //   <a href='/${pluralLinkedType}/${entry.id}' class='bubbled b-link'>
  //     //     ${entry.name}
  //     //   </a>
  //     // `);
  //     $topicLink.process();
  //
  //     $topicLinked.hide();
  //     $(LINKED_TYPE_USER_SELECT).hide();
  //     $('.topic-link', $form).show();
  //   })
  //   .on('keypress', e => {
  //     if ((e.keyCode === 10) || (e.keyCode === 13)) {
  //       e.preventDefault();
  //     }
  //   });
});
