// редактирование аниме/манги
$('.slide > .item-editor').live('ajax:success cache:success', function(e) {
  var $editor = $('.item-editor-container', this);
  if ($editor.length) {
    // редактор
    new ItemEditorNew($('.item-editor-container').data('kind'), 'description', $(this));
    // фиксы DOM
    process_current_dom();
  }

  // кадры
  var $images_list = $('.screenshots-editor .images-list', this);
  if ($images_list.length) {
    $images_list.find('a').fancybox($.galleryOptions);
    $images_list.dragsort({
      dragSelector: '.image-container',
      dragSelectorExclude: '.image-delete, .image-delete-confirm, .image-delete-cancel',
      dragEnd: function() { },
      dragBetween: false,
      placeHolderTemplate: '<div class="image-container"><div class="placeholder"></div></div>'
    });
  }
  var $screenshots_uploader = $('.screenshots-uploader', this);
  init_uploader($screenshots_uploader);

  // видео
  $('.videos-list a', this).fancybox($.youtubeOptions);

  // меню
  $('.actions').hide();
  $('.editions').show();
}).live('ajax:clear', function() {
  // очистка контента, чтобы в следующий раз загрузился новый
  //if ($.isReady) {
    //$(this).append('<div class="clear-marker"></div>');
  //}

  _.delay(function() {
    if (!$('.editions .selected').length) {
      $('.actions').show();
      $('.editions').hide();
    }
  });
});

// клик по кнопке редактирования в меню
$('.actions .edit-entry').live('click', function() {
  $('.actions').hide();
  $('.editions').show();
});
// клик по кнопке отмены в меню
$('.editions .edit-cancel').live('click', function() {
  $('.actions').show();
  $('.editions').hide();

  if ($('.item-editor').hasClass('selected')) {
    $('.slider-control-info').trigger('click');
  }
});
// клик по кнопке отмены в редакторе
$('.item-editor .item-cancel').live('click', function() {
  $('.editions .edit-cancel').trigger('click');
});

function init_uploader($root) {
  var $uploads = $root.find('.uploads');

  $root.find('.upload-area').shikiFile({
    progress: $root.find('.upload-progress'),
    input: $root.find('.item-upload input'),
    maxfiles: 250
  })
  .on('upload:before', function() {
    $uploads.show();
  })
  .on('upload:after', function() {
    $uploads.hide();
  })
  .on('upload:success', function(e, response) {
    $('.uploaded-container', $root).append(response.html)
        .find('a')
        .fancybox($.galleryOptions);
  });
}
