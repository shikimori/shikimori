pageLoad('dashboards_show_v2', () => {
  alignGeneratedNews();
  $(document).on('resize:debounced orientationchange', alignGeneratedNews);
});

pageUnload('dashboards_show_v2', () => {
  $(document).off('resize:debounced orientationchange', alignGeneratedNews);
});

function alignGeneratedNews() {
  const $target = $('.generated-news');

  if (!$target.is(':visible')) {
    return; // disable on iphone
  }

  $target.children().show();

  const $siblings = $target.siblings().children('.b-news_wall');
  const siblingsHeight = $siblings.outerHeight();

  shorten($target, $target.children(), siblingsHeight, 0);
}

function shorten($target, $targetChildren, siblingsHeight, indexToHide) {
  const targetHeight = $target.innerHeight();

  if (targetHeight - 5 > siblingsHeight) {
    $targetChildren.eq($targetChildren.length - 1 - indexToHide).hide();
    shorten($target, $targetChildren, siblingsHeight, indexToHide + 1);
  }
}
