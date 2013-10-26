// забор аниме на перевод
$('.translate-lock,.locked-by.unlockable').live('ajax:success', function(e, data, status, xhr) {
  $(this).replaceWith(data.html);
});
$('.slide .translation_planned,.slide .translation_finished').live('ajax:success cache:success', function(e, data, status, xhr) {
 $(this).masonry({
    itemSelector : '.goal'
  });
});
$(function() {
  var $node = $('.slide .translation_planned,.slide .translation_finished');
  if ($node.children().length) {
    $node.masonry({
      itemSelector : '.goal'
    })
  }
});
