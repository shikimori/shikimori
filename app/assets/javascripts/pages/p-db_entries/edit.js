pageLoad('.db_entries-edit', () => {
  const $merge = $('.merge_target_id');
  if ($merge.length) {
    $merge
      .find('input[type=text]')
      .completable()
      .on('autocomplete:success', ({ currentTarget }, entry) => {
        const type = $merge.data('type');
        const pluralType = `${type.toLowerCase()}s`.replace('ranobes', 'ranobe');

        $merge.find('input[type=hidden]').val(entry.id);
        $merge
          .append(`
            <a href='/${pluralType}/${entry.id}' class='bubbled b-link'>
              ${entry.name}
            </a>
          `)
          .process();
        $(currentTarget).remove();
      });
  }
});
