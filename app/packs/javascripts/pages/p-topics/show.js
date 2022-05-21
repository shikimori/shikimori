import { loadImagesFinally } from '@/utils/load_image';

pageLoad('critiques_show', async () => {
  const $stars = $('.body-inner .critique-stars');

  if ($stars.length) {
    const $firstImage = $('.body-inner .b-poster').first();

    await loadImagesFinally('.body-inner');
    const imageOffset = $firstImage.offset();

    if (imageOffset && (imageOffset.top - ($stars.offset().top + $stars.outerHeight())) < 15) {
      $firstImage.addClass('critique-poster');
    }
  }
});
