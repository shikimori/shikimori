// инициализация тултипов
$('.slide > div.favourites').live('ajax:success cache:success', function(e, data) {
  if (!('tooltips_initialized' in arguments.callee)) {

    arguments.callee.tooltips_initialized = true;
  }
});
