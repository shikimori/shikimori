$('.slide > .stats').live('ajax:success cache:success', function(e) {
  //if (e.type == 'cache:success' && 'mutex' in arguments.callee) {
  if ('mutex' in arguments.callee) {
    return;
  }
  arguments.callee.mutex = true;

  $('.stat-block').each(function(k, v) {
    var type = v.id.match(/-(\w+)/)[1];
    var $chart = $('#' + type + '-chart');
    // если график виден, инициализируем его, в противном случае показываем его позже
    if ($chart.is(':visible')) {
      init_charts(type);
    } else {
      $chart.one('show', function() {
        init_charts(type);
      });
    }
  });

  var $this = this;

  $('.suggest', $this).make_completable('Имя пользователя...', user_req_complete);
  // сброс id пользователя, чтобы по дефолту был не выбран пользователь для рекомендаций
  $('#comment_commentable_id', $this).val(0);
  // отключаем добавление коментов при сабмите формы
  $('.shiki-editor form', $this).data('do-not-add-comments', true);

  // при отправке рекомендаций проверяем, что указан пользователь
  $('.shiki-editor form', $this).on('submit', function() {
    if ($('#comment_commentable_id', $this).val() == 0) {
      $.flash({alert: 'Укажите пользователя'})
      $('.suggest', $this).focus();
      return false;
    }
  });

  // при успешной отправке рекомендации надо сбросить пользователя в форме
  $('.shiki-editor form', $this).on('ajax:success', function(e) {
    $('#comment_commentable_id', $this).val(0);
    $('.suggest', $this).val('').trigger('blur');
  });
});

// автодополнени на имя пользователя для рекомендации
function user_req_complete(e, id, text, label) {
  if (!id || !text) {
    return;
  }
  $('.suggest', '.slide > .stats').val(text);
  $('#comment_commentable_id', '.slide > .stats').val(id);
  $('.editor textarea', '.slide > .stats').focus();
}
