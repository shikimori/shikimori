pageLoad('contests_grid', () => {
  placeFinal();
  $(window).on('resize', placeFinal);
});

pageUnload('contests_grid', () => {
  $(window).off('resize', placeFinal);
});

function placeFinal() {
  let height;
  const $grid = $('.contest-grid');
  const $final = $grid.find('.final');
  let $top = $grid.find('.winners .round:last-child .entry:first-child');
  let $bottom = $grid.find('.losers .round:last-child .entry:first-child');

  // если $bottom - пусто, значит у нас контест без дополнительных раундов
  if ($bottom.length) {
    height = ($bottom.offset().top - $top.offset().top) + 1;
  } else {
    $top = $grid.find('.winners .round:last-child .entry:first-child');
    $bottom = $grid.find('.winners .round:last-child .entry:last-child p:first-child');
    height = $bottom.offset().top - $top.offset().top - 23;
  }

  $final.css({
    height,
    width: 1,
    top: ($top.offset().top + $top.outerHeight()) - 1,
    left: $top.offset().left + $top.outerWidth()
  });

  const $entry = $final.find('.entry');

  $entry.css({
    marginTop: (height / 2) - $entry.outerHeight()
  });
}
