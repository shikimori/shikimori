import imagesLoaded from 'imagesloaded';

pageLoad('topics_show', async () => {
  const $stars = $('.body-inner .review-stars');

  if ($stars.length) {
    const $firstImage = $().first();

    await imagesLoaded('.body-inner img.b-poster');
    const imageOffset = $firstImage.offset();

    if (imageOffset && imageOffset.top === ($stars.offset().top + $stars.outerHeight())) {
      $firstImage.addClass('review-poster');
    }
  }
});
