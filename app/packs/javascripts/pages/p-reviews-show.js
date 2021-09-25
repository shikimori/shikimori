import delay from 'delay';

import { loadImagesFinally } from '@/helpers/load_image';

pageLoad('reviews_show', async () => {
  // expand displayed comment and do not expand all replies to that comment
  await loadImagesFinally('.b-review');
  await delay(250);
  $('.b-height_shortener .expand').click();
});
