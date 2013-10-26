// редактор элемента
function ItemEditorNew(name, field, root) {
  var $editor = root || $('.editable');
  var $textarea = $('#change_value', $editor);
  var $source = $('#change_source', $editor);
  $('.source .notice', $editor).tipsy({gravity: 's'});

  $editor.on('editor:show', function() {
    $('.item-content', $editor).hide();
    $('.item-change', $editor).hide();
    $('.item-save', $editor).show();
    $('.item-apply', $editor).show();
    $('.item-cancel', $editor).show();
    $('.item-delete', $editor).show();
    $('.item-content-editor', $editor).show();
    $textarea.focus();
  });

  $editor.on('editor:hide', function() {
    $('.item-content', $editor).show();
    $('.item-change', $editor).show();
    $('.item-save', $editor).hide();
    $('.item-apply', $editor).hide();
    $('.item-cancel', $editor).hide();
    $('.item-delete', $editor).hide();
    $('.item-content-editor', $editor).hide();
  });

  $('.item-change', $editor).on('click', function() {
    if (!IS_LOGGED_IN) {
      $('#sign_in').trigger('click');
      return false;
    }
    // замена общих html тегов
    $textarea.val($textarea.val().replace(/<br ?\/?>/g, '\n'));

    $editor.trigger('editor:show');
  });

  $('.item-save', $editor).on('click', function() {
    $('.item-content-editor form', $editor).submit();
  });

  $('.item-apply', $editor).on('click', function() {
    $('.item-content-editor form #apply', $editor).val('yes');
    $('.item-content-editor form', $editor).data('apply', true)
        .attr('data-remote', null)
        .submit();
  });
  // для редактора картинок отдельная логика
  $('.item-content-editor form', $editor).on('submit', function(e) {
    var $images_list = $editor.find('.images-list.screenshots-position');
    if ($images_list.length) {
      var ids = $images_list.find('img').map(function() {
        return $(this).data('id');
      });
      $textarea.val($.makeArray(ids).join(','));
    }
  });

  $('.item-content-editor form', $editor).on('ajax:success', function(e) {
    var $form = $(this);
    $.flash({info: 'Начинается перезагрузка страницы'});

    if ($form.data('apply')) {
      $form.data('apply', false);
      $.flash({notice: 'Изменение сохранено'});
    } else {
      $.flash({notice: 'Изменение сохранено и будет в ближайшее время рассмотрено модератором'});
    }

    _.delay(function() {
      location.reload();
    }, 100);

    return false;
  });

  $('.item-delete', $editor).on('click', function() {
    $('.edit-controls', $editor).hide();
    $('.delete-controls', $editor).show();
  });

  // подтверждение удаления
  $('.item-delete-confirm', $editor).on('click', function() {
    $(this).parents('form').submit();
  });
  // отмена удаления
  $('.item-delete-cancel', $editor).on('click', function() {
    $('.edit-controls', $editor).show();
    $('.delete-controls', $editor).hide();
  });
}
