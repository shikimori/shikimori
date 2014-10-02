function ImageBoardTagsSuggest(loader) {
  $('.danbooru-suggest .tag-suggest').completable('Пожалуйста, укажите тег...', function(e, id, text, label) {
    var $this = $(this);
    if (!id || !text) {
      return;
    }

    $this.val(text);
    loader.change_tags(text);
    $('.danbooru-suggest .item-save').css('visibility', 'visible');

    $this.trigger('completable:callback');
  });

  // клик по тегу поиска в заголовке галереи - показ поля для задания тега
  $(document.body).on('click', '.images .search-tag', function() {
    $('.danbooru-suggest').toggle();
    if ($('.danbooru-suggest').is(':visible')) {
      $('.danbooru-suggest input').focus();
    }
    $('.images .suggest-not-found').hide();
  });

  // сохранение указанного пользователем тега
  $(document.body).on('click', '.danbooru-suggest .item-save', function() {
    $('.danbooru-suggest').find('#change_value').val($('.danbooru-suggest .tag-suggest').val());
    $('.danbooru-suggest').find('form').submit();
  });
  $(document.body).on('ajax:success', '.danbooru-suggest form', function() {
    $.flash({notice: 'Изменение сохранено и будет в ближайшее время рассмотрено модератором. Домо аригато.'});

    $('.danbooru-suggest .item-save').css('visibility', 'hidden');
    $('.images .search-tag').html($('.danbooru-suggest input').val())
                                  .trigger('click');
  });

  // если ничего не найдено, то надо показать блок suggest
  $(document.body).on('danbooru:zero', '.danbooru .images-list', function() {
    $('.images .danbooru-suggest').show();
    $('.images .suggest-not-found').show();
    $('.danbooru').hide();
  });

  //if (_.isEmpty($('.images .search-tag').text())) {
    //$('.danbooru .images-list').trigger('danbooru:zero');
  //}
}
