// add to favourites
$('.favourite').live('ajax:success', function(e) {
  $(this).parent().children('.favourite').show()
         .filter('.active').hide();
});
$('.favourite').live('ajax:failure', function(e) {
  $(this).parent().children('.favourite').removeClass('active');
});
$('.favourite').live('click', function(e) {
  $(this).parent().children('.favourite').removeClass('active');
  $(this).addClass('active');
});

// добавление в избранное
$('.fav-add .favourite-add').live('ajax:success', function() {
  var $this = $(this);
  var kind = $this.data('kind');
  if (kind) {
    $('.favourite-remove[data-kind='+kind+']').parents('li').show();
  } else {
    $('.favourite-remove').parents('li').show();
  }
  $this.parents('li').hide();
});
// удаление из избранных
$('.fav-remove .favourite-remove').live('ajax:success', function() {
  var $this = $(this);
  var kind = $this.data('kind');
  if (kind) {
    $('.favourite-add[data-kind='+kind+']').parents('li').show();
  } else {
    $('.favourite-add').parents('li').show();
  }
  $this.parents('li').hide();
});
