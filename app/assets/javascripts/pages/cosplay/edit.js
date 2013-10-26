$(function() {
  $('.item-save, .button.save').click(function() {
    $(this).parents('form').submit();
  });

  $('.item-add').trigger('click', true);
  $('.images-list').parent().gallery();
});

$('.item-add').live('click', function(e, no_focus) {
  var $this = $(this);
  var is_anime = $this.hasClass('anime');
  var is_manga = $this.hasClass('manga');
  var is_tag = $this.hasClass('tag');
  var type = is_anime ? 'anime' : (is_manga ? 'manga' : (is_tag ? 'tag' : 'character'));
  var content = '<div class="entry ' + type + '-entry"><input type="text" data-autocomplete="/' + type + 's/autocomplete/" class="' + type + '-suggest common" /></div>';
  var $input = $this.parent()
      .next()
      .append(content)
        .find('input').make_completable(is_anime ? 'Введите название аниме...' : (is_manga ? 'Введите название манги...' : (is_tag ? 'Введите название тега...' : 'Введите имя персонажа...')), function(e, id, text, label) {
    if (!id || !text) {
      return;
    }
    var $this = $(e.target);
    $this.parent().parent().prev().find('.item-add').trigger('click');
    if (is_anime || is_manga) {
      var $new_node = $('<span class="item-minus"></span><input type="hidden" name="' + type +
                        's[]" value="' + id + '" /><span class="title" title="' + text + '">' + text + '</span>');

    } else if (is_tag) {
      var $new_node = $('<span class="item-minus"></span><input type="hidden" name="' + type +
                        's[]" value="' + text + '" /><span class="title" title="' + text + '">' + text + '</span>');
    } else {
      var $new_node = $('<input type="hidden" name="' + type + 's[]" value="' + id + '" />' + label);
      $new_node.find('.character.name').append('<span class="item-minus"></span>');
    }
    $this.replaceWith($new_node);
  });
  if (!no_focus) {
    $input.focus();
  }
});

$('.tag-suggest').live('keypress', function(e) {
  if (e.keyCode == 13 && this.value != '') {
    $('.tag-suggest').trigger('result', [1, this.value, '']);
  }
});

$('#move_to_id,#move_from_id').live('keypress', function(e) {
  if (e.keyCode == 13 && this.value != '') {
    $(this).parents('form').submit();
  }
});

$('.completable-title .item-minus').live('click', function() {
  $(this).parent().next().children('div:has(input[type=hidden])').remove();
});
$('.tag-entry .item-minus, .anime-entry .item-minus, .manga-entry .item-minus').live('click', function() {
  $(this).parent().remove();
});
$('.character-entry .item-minus').live('click', function() {
  $(this).parent().parent().parent().remove();
});
$('#move_to_confirm,#move_from_confirm').live('click', function() {
  $(this).hide();
  $(this).next().show()
         .next().show().focus()
         .next().show();
});
