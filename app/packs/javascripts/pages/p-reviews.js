import delay from 'delay';

pageLoad('reviews_show', async () => {
  await delay(25);
  const editor = $('.shiki_editor-selector').view();
  await editor.initialization.promise;
  if (editor.cacheProcessed) {
    await editor.cacheProcessed.promise;
  }

  const { reply } = gon;
  if (gon.reply) {
    editor.replyComment(reply);
    editor.reprocessCache();

    const url = window.location.href.replace(/\/reply$/, '');
    if (url !== window.location.href) {
      window.history.replaceState({ turbolinks: true, url }, '', url);
    }
  }
});
