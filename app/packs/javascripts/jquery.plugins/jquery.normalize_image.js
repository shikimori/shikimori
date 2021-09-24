import delay from 'delay';
import { imagePromiseFinally } from '@/helpers/load_image';

// почему-то без задержки не работает
function checkImage(image, options) {
  const $image = $(image);

  const imageWidth = image.naturalWidth || $image.width();
  const imageHeight = image.naturalHeight || $image.height();

  if ((imageWidth > 300) && !$image.attr('width') && !$image.attr('height')) {
    const normalizationClass = imageWidth > imageHeight ?
      'normalized_width' :
      'normalized_height';
    $image.addClass(normalizationClass);
  }

  const $link = $image.parent();

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
    return this.each(async function() {
      const image = this;

      await imagePromiseFinally(image);
      await delay();

      if (image.loading === 'lazy' && !image.naturalWidth && !image.complete) {
        $(image).on('load', () => checkImage(image, options));
      } else {
        checkImage(image, options);
      }
    });
  }
});
