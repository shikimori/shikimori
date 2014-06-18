$('.slide > .images').live('ajax:success cache:success', function(e) {
  $('.danbooru').show();
  if ('mutex' in arguments.callee) {
    return;
  }
  arguments.callee.mutex = true;

  $('.original-gallery-container', this).gallery();

  var loader = window.loader = new GalleryManager($('.danbooru .images-list'), $('.danbooru .b-postloader'), 144);
  var suggest = new ImageBoardTagsSuggest(loader);

  $.force_appear();
}).live('ajax:clear', function() {
  $('.danbooru').hide();
});
