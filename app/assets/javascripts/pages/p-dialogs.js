pageLoad('dialogs_index', 'dialogs_show', () => {
  $('textarea:appeared').focus();

  $('.b-topic').on('preview:params', '.b-shiki_editor', ({ currentTarget }) => {
    const $form = $(currentTarget).closest('form');

    return {
      kind: $form.find('input[name="message[kind]"]').val(),
      from_id: $form.find('input[name="message[from_id]"]').val(),
      to_id: $form.find('input[name="message[to_id]"]').val()
    };
  });
});
