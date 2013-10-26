$('.slide > .info').live('ajax:success cache:success', function(e) {
  if ('mutex' in arguments.callee) {
    return;
  }
  arguments.callee.mutex = true;

  var $this = $(this);

  // редактор описания
  var kind = $('.entry-content-slider').attr('class').indexOf('manga') == -1 ? 'anime' : 'manga';
  var $editor = $('.right-column', $this);

  $editor.on('editor:show', function() {
    $('.left-column-wrap', $this).addClass('disabled');
  });
  $editor.on('editor:hide', function() {
    $('.left-column-wrap', $this).removeClass('disabled');
  });

  $('.rating.notice').tipsy({gravity: 's'});
  $('.status-date.notice').tipsy({gravity: 's'});

  $('.extra .images-list a', $this).fancybox($.galleryOptions);
  $('.extra .videos-list a', $this).fancybox($.youtubeOptions);

  // rating
  $('.scores', $this).makeRateble({ round_values: false });
});

// похожие аниме, подгружаемые для гостей аяксом
$('.related-entries-loader').live('ajax:success', function() {
  var $this = $(this);
  $this.removeClass('related-entries-loader');
  process_current_dom($this);
});

// клик по загрузке других названий
$('.other-names.click-loader').live('ajax:success', function(e, data) {
  $(this).parents('p')
         .replaceWith(data);
});

// раскрытие свёрнутого блока связанного
$('.related-shower').live('click', function() {
  var $this = $(this);
  $this.addClass('selected')
       .data('disabled', true);

  $this.siblings('span')
       .removeClass('selected')
       .data('disabled', false);

  $(this).hide()
          .next()
            .show();
});

// переключение типа комментариев
$('.entry-comments .link').live('ajax:before', function(e) {
  var $this = $(this);
  $this.addClass('selected')
       .data('disabled', true);

  $this.siblings('span')
       .removeClass('selected')
       .data('disabled', false);

  $this.parents('.entry-comments')
       .find('.comments-container')
       .animate({opacity: 0.3});
}).live('ajax:success', function(e, data) {

  $container = $(this).parents('.entry-comments').find('.comments-container').animate({opacity: 1});
  $container.children(':not(.shiki-editor)')
            .remove()
  $container.append(data.content);
});

// дополнительные ссылки под текстом аниме
$('.additional-links .link-reviews').live('click', function(e) {
  $('.slider-control-reviews').trigger('click');
});
$('.additional-links .link-comments').live('click', function(e) {
  $.scrollTo('.entry-comments');
  $('.options-floated .link-comments').trigger('click');
});
$('.additional-links .link-comment-reviews').live('click', function(e) {
  $.scrollTo('.entry-comments');
  $('.options-floated .link-comment-reviews').trigger('click');
});
