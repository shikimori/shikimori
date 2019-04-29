pageLoad('topics_show', () => {
  const $stars = $('.body-inner .review-stars');

  if ($stars.length) {
    const $firstImage = $('.body-inner img.b-poster').first();

    $firstImage.imagesLoaded(() => {
      const imageOffset = $firstImage.offset();

      if (imageOffset && imageOffset.top === ($stars.offset().top + $stars.outerHeight())) {
        $firstImage.addClass('review-poster');
      }
    });
  }
});
