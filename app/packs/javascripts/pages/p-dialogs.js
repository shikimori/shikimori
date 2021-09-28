import delay from 'delay';

pageLoad('dialogs_show', async () => {
  await delay(25);
  const editor = $('.shiki_editor-selector').view();
  await editor.initialization.promise;

  const { reply } = gon;
  if (gon.reply) {
    editor.replyComment(reply);

    const url = window.location.href.replace(/\/reply\/.*$/, '');
    if (url !== window.location.href) {
      window.history.replaceState({ turbolinks: true, url }, '', url);
    }
  } else {
    editor.focus();
  }
});
