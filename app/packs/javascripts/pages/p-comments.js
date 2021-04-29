import delay from 'delay';
import imagesLoaded from 'imagesloaded';

pageLoad('comments_show', async () => {
  // expand displayed comment and do not expand all replies to that comment
  await imagesLoaded('.b-comment');
  await delay(250);
  $('.b-height_shortener .expand').click();
});
