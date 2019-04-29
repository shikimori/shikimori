import delay from 'delay';

pageLoad('comments_show', async () => {
  await delay(250);

  $('.b-comment').imagesLoaded(() =>
    $('.b-height_shortener .expand').click()
  );
});
