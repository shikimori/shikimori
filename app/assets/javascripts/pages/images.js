$(function() {
  var $image = $('#cropbox');
  var $preview = $('#preview');
  var ratio = 1;
  var image_width;
  var image_height;

  var update_crop = function(coords) {
    if (coords.x2 > 0 && coords.y2 > 0) {
      $('.image-editor .buttons .image-crop').data('crop-possible', true);
    } else {
      $('.image-editor .buttons .image-crop').data('crop-possible', false);
    }
    var rx = 100.0 / coords.w;
    var ry = 100.0 / coords.h;
    //$preview.css({
      //width: Math.round(image_width * ratio * rx) + 'px',
      //height: Math.round(image_height * ratio * ry) + 'px',
      ////marginLeft: '-' + Math.round(coords.x) + 'px',
      ////marginTop: '-' + Math.round(coords.y) + 'px'
    //});
    //var preview_ratio = image_width / $preview.width() * ratio;
    $("#crop_x").val(Math.round(coords.x / ratio));
    $("#crop_y").val(Math.round(coords.y / ratio));
    $("#crop_w").val(Math.round(coords.w / ratio));
    $("#crop_h").val(Math.round(coords.h / ratio));
  }

  $.cacheImage($('#cropbox').attr('src'), {load: function() {
    var page_content_width = $('.image-editor').width();
    image_width = $image.width() * 1.0;
    image_height = $image.height() * 1.0;

    if (image_width > page_content_width) {
      $image.css('width', page_content_width);
      $preview.css('width', page_content_width);
      ratio = page_content_width / image_width;
    }
    $image.Jcrop({
      onChange: update_crop,
      onSelect: update_crop
      //setSelect: [0, 0, 500, 500],
      //aspectRatio: 1
    });
    update_crop({
        x: 0,
        y: 0,
        x2: 0,
        y2: 0,
        w: $image.width(),
        h: $image.height()
      });
  }});
});

// возврат назад
$('.image-editor .buttons .go-back').live('click', function() {
  location.href = $(this).attr('action');
});
// сабмит формы обновления картинки
$('.image-editor .buttons .image-crop').live('click', function() {
  if ($(this).data('crop-possible')) {
    $('.edit_image').submit()
  } else {
    $.flash({alert: 'Выделите на картинке область, до которой надо обрезать изображение'});
  }
});
// сабмит формы удаления картинки
$('.image-editor .buttons .image-delete').live('click', function() {
  $(this).parents('.image-editor').find('form.deletion').submit();
});
// загрузка картинки
$('.upload-container input').live('change', function() {
  $(this).parents('form').submit();
});
