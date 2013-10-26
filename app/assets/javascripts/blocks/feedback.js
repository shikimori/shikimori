// оставить отзыв
$(document.body).on('ajax:success', '.feedback', function(e, data) {
  $('body').append(data);
  var $feedback_container = $('.feedback-container');
  $feedback_container.css('left', $('.page').offset().left);
  $feedback_container.find('form').bind('ajax:success', function() {
    $('#shade').trigger('click');
  });

  if (!IS_LOGGED_IN) {
    $('<input type="hidden" name="comment[feedback]"/><div class="hidden-block email"><p><label for="comment_email">E-mail: </label><input class="link-value" type="text" id="comment_email" name="comment[email]" placeholder="Сюда придёт ответ..." /></p></div>')
      .insertAfter($('.body', $feedback_container));
  }
  $('<input type="hidden" name="comment[location]"/>')
    .val(location.href)
    .insertAfter($('.body', $feedback_container));
  $('<input type="hidden" name="comment[user_agent]"/>')
    .val(navigator.userAgent)
    .insertAfter($('.body', $feedback_container));

  process_current_dom();

  $(this).attr('data-remote', null).click(function() {
    $feedback_container.show();
    $('#shade').trigger('show', 0.2);
    $('#shade').one('click', function() {
      $feedback_container.hide();
    });
    $feedback_container.find('textarea').attr('value', '').focus();
  }).trigger('click');
});
