import delay from 'delay';

pageLoad('comments_show', async () => {
  await delay(250);

  // expand displayed comment and do not expand all replies to that comment
  $('.b-comment').first().imagesLoaded(() =>
    $('.b-height_shortener .expand').click()
  );
});
