import { loadImagesFinally } from '@/helpers/load_image';

pageLoad('topics_show', async () => {
  const $stars = $('.body-inner .critique-stars');

  if ($stars.length) {
    const $firstImage = $().first();

    await loadImagesFinally('.body-inner');
    const imageOffset = $firstImage.offset();

    if (imageOffset && imageOffset.top === ($stars.offset().top + $stars.outerHeight())) {
      $firstImage.addClass('critique-poster');
    }
  }
});
