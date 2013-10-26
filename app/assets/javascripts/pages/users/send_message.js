// private message
function show_private_message_form(user_id, top, text_getter) {
  if (!IS_LOGGED_IN) {
    $('#sign_in').trigger('click')
    return false;
  }
  $shade = $('#shade');
  if ($shade.is(':animated')) {
    return false;
  }

  $shade.css({opacity: 0.5}).show();
  var editor = $('#message_body').ckeditor_fixed({
    height: 300,
    autoGrow_minHeight: 300,
    autoGrow_maxHeight: 500
  }).data('ckeditorInstance');
  editor.setData("");
  if (text_getter) {
    _.delay(function() {
      editor.insertHtml(text_getter());
      editor.focus();
    }, 300);
  }
  $('#message_dst_id').attr('value', user_id);
  show_form.apply({id: 'private-message'}, [top]);
  return false;
}

$('#private-message-form').live('ajax:success', function(e, data, status, xhr) {
  var $this = $(this);
  hide_form.apply($this);
  $('#shade').animate({opacity: 0}, function() {
    $(this).hide();
  });

  $this.find('#message_subject').attr('value', '');
  var $message_body = $this.find('#message_body');
  if ($message_body.data('ckeditorInstance')) {
    $message_body.data('ckeditorInstance').setData('');
    $message_body.attr('value', '');
  } else {
    $message_body.attr('value', '').trigger('blur');
  }
});
