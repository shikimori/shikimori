$('.slide .settings').live('cache:success ajax:success', function() {
  if ('mutex' in arguments.callee) {
    return;
  }
  arguments.callee.mutex = true;

  $('.anime-suggest').make_completable('Название аниме...', accept_complete);
  $('.manga-suggest').make_completable('Название манги...', accept_complete);
  $('.character-suggest').make_completable('Имя персонажа...', accept_complete);
  $('.moderator-suggest,.admin-suggest,.kick-suggest').make_completable('Имя пользователя...', accept_complete);
});

function accept_complete(e, id, text, label) {
  if (!id || !text) {
    return;
  }
  var $this = $(this);
  var bubbled = false;
  if ($this.hasClass('anime-suggest')) {
    var type = 'animes';
    var url = '/animes/'+id;
    bubbled = true;
  } else if ($this.hasClass('manga-suggest')) {
    var type = 'mangas';
    bubbled = true;
    var url = '/mangas/'+id;
  } else if ($this.hasClass('character-suggest')) {
    var type = 'characters';
    var url = '/characters/'+id;
    bubbled = true;
  } else if ($this.hasClass('moderator-suggest')) {
    var type = 'moderators';
    var url = '/'+id;
  } else if ($this.hasClass('admin-suggest')) {
    var type = 'admins';
    var url = '/'+id;
  } else if ($this.hasClass('kick-suggest')) {
    var type = 'kicks';
    var url = '/'+id;
  }
  var $container = $this.next().next().children('.container');
  if ($container.find('[value="'+id+'"]').length) {
    return;
  }
  $container.append(
    '<li>' +
      '<span class="item-minus"></span>' +
      '<input type="hidden" name="'+type+'[]" value="'+id+'" />' +
      '<a href="'+url+'" ' +
        (bubbled ? 'class="bubbled"' : '') +
        '>'+text+'</a>' +
    '</li>'
  );
  if (bubbled) {
    process_current_dom();
  }
  $this.attr('value', '');
}

$('.settings .item-minus').live('click', function() {
  $(this).parent().remove();
});

$('.settings .save, .settings .item-save').live('click', function(e) {
  if (e.clientX != 0) { // что за странная проверка?
    $(this).parents('form').trigger('submit', true);
  }
});
