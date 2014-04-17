# оставить отзыв
$(document.body).on 'ajax:success', '.feedback', (e, data) ->
  $('body').append data

  $feedback_container = $('.feedback-container')

  $feedback_container.css(left: $('.page').offset().left)
    .find('form')
    .on 'ajax:success', ->
      $('#shade').trigger "click"

  $("<input type=\"hidden\" name=\"comment[feedback]\"/><div class=\"hidden-block email\"><p><label for=\"comment_email\">E-mail: </label><input class=\"link-value\" type=\"text\" id=\"comment_email\" name=\"comment[email]\" placeholder=\"Сюда придёт ответ...\" /></p></div>")
    .insertAfter $(".body", $feedback_container) unless IS_LOGGED_IN
  $("<input type=\"hidden\" name=\"comment[location]\"/>")
    .val(location.href)
    .insertAfter $('.body', $feedback_container)
  $("<input type=\"hidden\" name=\"comment[user_agent]\"/>")
    .val(navigator.userAgent)
    .insertAfter $('.body', $feedback_container)

  process_current_dom()

  $(@)
    .attr('data-remote', null)
    .click( ->
      $feedback_container.show()
      $('#shade').trigger 'show', 0.2
      $('#shade').one 'click', ->
        $feedback_container.hide()

      $feedback_container
        .find('textarea')
        .attr(value: '')
        .focus()
    ).trigger "click"
