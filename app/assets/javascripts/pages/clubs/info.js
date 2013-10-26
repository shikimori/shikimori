// инициализация masonry для картинок
$('.slide .info').live('ajax:success cache:success', function() {
  if ('mutex' in arguments.callee) {
    return;
  }
  arguments.callee.mutex = true;

  group_gallery(this);
});
