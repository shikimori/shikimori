import delay from 'delay';

page_load('comments_show', async () => {
  await delay();
  $('.b-comment').imagesLoaded(() =>
    $('.b-height_shortener .expand').click()
  );
});
