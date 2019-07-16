import delay from 'delay';

// почему-то без задержки не работает
function checkImage($image, options) {
  const $link = $image.parent();

  const imageWidth = $image[0].naturalWidth || $image.width();
  const imageHeight = $image[0].naturalHeight || $image.height();

  if ((imageWidth > 300) && !$image.attr('width') && !$image.attr('height')) {
    const normalizationClass = imageWidth > imageHeight ?
      'normalized_width' :
      'normalized_height';
    $image.addClass(normalizationClass);
  }

  if (options.appendMarker &&
    $link.attr('href') && !$link.children('.marker').exists() &&
    ((imageWidth > 300) && (imageHeight > 300))
  ) {
    $link.append(`<span class='marker'>${imageWidth}x${imageHeight}</span>`);
  }

  if (((imageWidth < 300) && (imageHeight < 300)) && ($link.tagName() === 'a') &&
    ($link.prop('href') === $image.prop('src'))
  ) {
    $image.unwrap();
  }
}

$.fn.extend({
  normalizeImage(options) {
    return this.each(function () {
      const $image = $(this);

      $image.imagesLoaded(async () => {
        await delay();
        checkImage($image, options);
      });
    });
  }
});
