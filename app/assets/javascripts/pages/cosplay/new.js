$('.item-add').live('click', function() {
  $('.images').append('<p><input type="text" name="cosplay_gallery[images][]" class="common" size="150" /><span class="right anime item-minus"></span></p>')
              .find('input').focus();
});
$('.item-minus').live('click', function() {
  $(this).parent().remove();
});
$('.save').live('click', function() {
  if (!_($('.cosplay-mod input')).all(function(v) { return v.value != ''; })) {
    alert('Заполните все поля!');
    return;
  }
  var $links = $('.cosplay-mod .links input');
  if ($links.length && _($links).all(function(v) { return v.value != ''; })) {
    $(this).parents('form').submit();
  } else {
    alert('Задайте картинки!');
  }
});
$(function() {
  $('.item-add').click();
});
