$('.slide > .ban').live 'ajax:success cache:success', (e, data) ->
  unless 'initialized' of arguments.callee
    arguments.callee.initialized = true

# перезагрузка вкладки после успешного бана
$(document.body).on 'ajax:success', '.ban form.ban', =>
  $('.slide > .selected').empty()
  $(".slider-control a[href$='#{location.href}']").parent().trigger 'slider:click'
