import delay from 'delay';

pageLoad('dialogs_index', 'dialogs_show', async () => {
  await delay(25);
  const editor = $('.b-shiki_editor, .b-shiki_editor-v2').view();
  await editor.initialization;
  editor.focus();
});
