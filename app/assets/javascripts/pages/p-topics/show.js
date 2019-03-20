pageLoad('topics_show', () => {
  const $stars = $('.body-inner .review-stars');

  if ($stars.length) {
    const $firstImage = $('.body-inner img.b-poster').first();

    $firstImage.imagesLoaded(() => {
      if ($firstImage.offset().top === ($stars.offset().top + $stars.outerHeight())) {
        $firstImage.addClass('review-poster');
      }
    });
  }
});
