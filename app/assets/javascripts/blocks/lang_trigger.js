$(document).on('turbolinks:load', () =>
  // переключение языка описания
  $('.b-lang_trigger').on('click', function() {
    const $english = $('.english');

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
  })
);
