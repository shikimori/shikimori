var root = '.slide > .reviews';
$(root).live('ajax:success cache:success', function(e, data) {
  var $root = $(this);

  // ajax:success может у комментариев сработать
  if (!$(e.target).hasClass('reviews')) {
    return;
  }
  _.delay(function() {
    $.force_appear();
  });
  $('.review-block .rate-block', $root).makeRateble();

  if (!data || !('notice' in data)) {
    // если мы перешли на обзоры с указанием id, подсветим нужный обзор
    var match = location.href.match(/\d+$/);
    if (match) {
      $('.review-'+match[0]).yellowFade();
    }
  }

  $('.review-block .comments.zero-margin')
        .removeClass('zero-margin')
        .addClass('preview');
}).live('ajax:success', function(e) {
  process_current_dom();
});

// клик на редактирование обзора
$('.review-block .content .item-edit', root).live('click', function() {
  var $control = $('.slider-control-reviews-edit').children();
  var url = $control.data('href');
  $control
      .data('href', $(this).data('href'))
      .trigger('click')
      .data('href', url);
  return false;
});
