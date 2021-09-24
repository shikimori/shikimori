import delay from 'delay';

import { loadImagesFinally } from '@/helpers/load_image';

pageLoad('comments_show', async () => {
  // expand displayed comment and do not expand all replies to that comment
  await loadImagesFinally('.b-comment');
  await delay(250);
  $('.b-height_shortener .expand').click();
});
