// переключение языка описания
$(document).on('click', '.lang-trigger', function() {
  var $english = $('.english');
  if ($english.is(':visible')) {
    $english.hide();
    $('.russian').show();
    $('.changes').show();

    $(this).children().html('eng');
  } else {
    $english.show();
    $('.russian').hide();
    $('.changes').hide();

    $(this).children().html('рус');
  }
});
