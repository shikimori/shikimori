import delay from 'delay';

const finishCollapse = $node =>
  $node
    .css({ height: '' })
    .removeClass('animated-height')
    .removeClass('animated-overflow').hide();

const finishExpand = $node =>
  $node
    .css({ height: '' })
    .removeClass('animated-height')
    .removeClass('animated-overflow');

$.fn.extend({
  animatedExpand(startHeigth = 0) {
    return this.each(async function () {
      const $node = $(this);
      finishCollapse($node);
      $node.show().css({ height: '' });

      const height = $node.outerHeight();
      $node
        .addClass('animated-overflow')
        .css({ height: `${startHeigth}px` });

      await delay();
      $node
        .addClass('animated-height')
        .css({ height })
        .data({ animated_direction: 'expand' });

      await delay(500);
      if ($node.data('animated_direction') === 'expand') {
        finishExpand($node);
      }
    });
  },

  animatedCollapse() {
    return this.each(async function () {
      const $node = $(this);
      finishExpand($node);

      const height = $node.outerHeight();
      $node
        .css({ height: `${height}px` })
        .addClass('animated-overflow');

      delay().then(() =>
        $node
          .addClass('animated-height')
          .css({ height: 0 })
          .data({ animated_direction: 'collapse' })
      );

      await delay(500);
      if ($node.data('animated_direction') === 'collapse') {
        finishCollapse($node);
      }
    });
  }
});
