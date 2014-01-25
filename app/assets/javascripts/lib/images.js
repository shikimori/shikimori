$('.image-container').live('mouseover', function() {
  if ($('.image-delete-confirm', this).hasClass('hidden')) {
    $('.image-delete', this).removeClass('hidden');
  }
}).live('mouseout', function() {
  $('.image-delete', this).addClass('hidden');
});
$('.image-delete').live('click', function() {
  var $container = $(this).parents('.image-container');

  $('img', $container).animate({opacity: 0.5}, 250);

  $('.image-delete', $container).addClass('hidden');
  $('.image-delete-confirm', $container).removeClass('hidden');
  $('.image-delete-cancel', $container).removeClass('hidden');
  return false;
});

$('.image-delete-cancel').live('click', function() {
  var $container = $(this).parents('.image-container');

  $('img', $container).animate({opacity: 1}, 250);

  $('.image-delete', $container).removeClass('hidden');
  $('.image-delete-confirm', $container).addClass('hidden');
  $('.image-delete-cancel', $container).addClass('hidden');
  return false;
});
$('.images-list .image-delete-confirm, .videos-list .image-delete-confirm').live('ajax:success', function() {
  var $masonry = $(this).parents('.masonry.images-list');
  $(this).closest('.image-container,.video').remove();
  if ($masonry.length) {
    $masonry.masonry('reload');
  }
  return false;
});
