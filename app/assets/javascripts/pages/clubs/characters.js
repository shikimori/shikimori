// инициализация masonry для картинок
$('.slide .characters').live('ajax:success cache:success', function() {
  if ('mutex' in arguments.callee) {
    return;
  }
  arguments.callee.mutex = true;

});

