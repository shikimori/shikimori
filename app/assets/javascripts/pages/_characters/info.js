$('.slide > .info').live('ajax:success cache:success', function(e) {
  if ('mutex' in arguments.callee) {
    return;
  }
  arguments.callee.mutex = true;

  // редактор описания
  var description_editor = new ItemEditorNew('character', 'description', $('.right-column .info'));
  // редактор руусского названия
  var russian_editor = new ItemEditorNew('character', 'russian', $('.left-column .names-block'));

  $('.left-column .edit-controls .item-change').on('click', function() {
    $('.left-column .item-content-editor #change_value').focus();
  });
});
