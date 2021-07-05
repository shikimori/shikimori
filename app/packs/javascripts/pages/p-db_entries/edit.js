pageLoad('.db_entries-edit', () => {
  $('.merge_target_id').each((_index, node) => {
    const $merge = $(node);
    const $form = $merge.closest('form');
    const $submit = $form.find('input[type=submit]');

    const $targetId = $form.find('input[name=target_id]');
    const $episode = $form.find('input[name=episode]');

    $form
      .find('input[data-autocomplete]')
      .completable()
      .on('autocomplete:success', ({ currentTarget }, entry) => {
        const type = $merge.data('type');
        const pluralType = `${type.toLowerCase()}s`
          .replace('ranobes', 'ranobe')
          .replace('persons', 'people');

        $targetId.val(entry.id);
        $merge
          .append(`
            <a href='/${pluralType}/${entry.id}' class='bubbled b-link'>
              ${entry.name}
            </a>
          `)
          .process();
        $(currentTarget).remove();
        syncSubmit($submit, $targetId, $episode);
      });

    $form.on('submit', e => {
      if (!isValid($targetId, $episode)) {
        e.preventDefault();
        e.stopImmediatePropagation();
      }
    });

    $episode.on('keyup change', () => {
      syncSubmit($submit, $targetId, $episode);
    });
  });
});

function syncSubmit($submit, $targetId, $episode) {
  $submit.prop('disabled', !isValid($targetId, $episode));
}

function isValid($targetId, $episode) {
  return !!$targetId.val() && (!$episode.length || !!$episode.val());
}
