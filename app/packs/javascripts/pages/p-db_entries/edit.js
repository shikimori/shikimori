pageLoad('.db_entries-edit', () => {
  const $merge = $('.merge_target_id');
  if ($merge.length) {
    const $targetId = $merge.find('input[type=hidden]');
    const $form = $merge.closest('form');

    $merge
      .find('input[type=text]')
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
        $form.find('input[type=submit]').prop('disabled', false);
      });

    $form.on('submit', e => {
      if (!$targetId.val()) {
        e.preventDefault();
        e.stopImmediatePropagation();
      }
    });
  }
});
