import delay from 'delay';

pageLoad('dialogs_show', async () => {
  await delay(25);
  const editor = $('.shiki_editor-selector').view();
  await editor.initialization.promise;
  editor.focus();
});
