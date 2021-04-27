pageLoad('pages_development', () => {
  const $ajax = $('.b-ajax');
  const $iframe = $('iframe');

  const height = $(window).height() - $ajax.offset().top - 5;

  $ajax.css({ width: '100%', height: height - 10 });
  $iframe.prop({ width: '100%', height });

  $iframe.on('load', () => {
    $ajax.hide();
    $iframe.removeClass('hidden');
  });
});
