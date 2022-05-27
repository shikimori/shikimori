import { loadImageFinally } from '@/utils/load_image';

pageLoad('critiques_show', async () => {
  const $stars = $('.body-inner .critique-stars');

  if ($stars.length) {
    const $firstImage = $('.body-inner .b-poster').first();
    if (!$firstImage.length) { return; }

    await loadImageFinally($firstImage[0]);
    const imageOffset = $firstImage.offset();

    if (imageOffset && (imageOffset.top - ($stars.offset().top + $stars.outerHeight())) < 15) {
      $firstImage.addClass('critique-poster');
    }
  }
});
