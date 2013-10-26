// автодополнение
$(function() {
  var $main_search = $('.main-search');
  var $search = $('.main-search input');
  var $popup = $('.main-search .popup');

  // из урла достаём текущий тип поиска
  var type = location.pathname.replace(/^\//, '').replace(/\/.*/, '');
  if (!searcheables[type]) {
    type = _.first(_.keys(searcheables));
  }

  // из урла достаём текущее значение поиска
  //var value = decodeURIComponent(location.pathname.replace(searcheables[type].regexp, '$1'));
  //if (value != location.pathname && !value.match(/^\d+-\w+/)) {
    //$search.val(value);
  //}

  // во всплывающей выборке типов устанавливаем текущий тип
  $('.type[data-type='+type+']', $popup).addClass('active');

  // автокомплит
  $search.data('type', type)
         .attr('placeholder', searcheables[type].title)
         .data('autocomplete', searcheables[type].autocomplete)
         .make_completable(null, function(e, id, text) {
    if (text) {
      this.value = text;
    }
    if (this.value === "" && !id) {
      return;
    }

    var type = $search.data('type');

    if (id) {
      if (type == 'users') {
        document.location.href = '/'+search_escape(text);
      } else {
        document.location.href = searcheables[type].id.replace('[id]', id);
      }
    } else {
      document.location.href = searcheables[type].phrase.replace('[phrase]', search_escape($search.val()));
    }
  }, $('.main-search .suggest-placeholder'));

  $search.on('parse', function() {
    $popup.addClass('disabled');
    _.delay(function() { $('.ac_results:visible').addClass('menu-suggest'); });
  });

  // переключение типа поиска
  $('.main-search .type').on('click', function() {
    var $this = $(this);
    if ($this.hasClass('active')) {
      return;
    }
    $this.addClass('active')
           .siblings()
           .removeClass('active');

    var type = $this.data('type');

    $search.data('type', type)
           .attr('placeholder', searcheables[type].title)
           .data('autocomplete', searcheables[type].autocomplete)
           .trigger('flushCache')
           .focus();

    // скритие типов
    $popup.addClass('disabled');
  });

  // включение и отключение выбора типов
  $popup.on('hover', function() {
    $search.focus();
  });
  $search.on('keypress', function() {
    $popup.addClass('disabled');
  });
  $search.on('click', function() {
    if ($('.ac_results:visible').length) {
      $popup.addClass('disabled');
    } else {
      $popup.toggleClass('disabled');
    }
  });
  $search.on('hover', function() {
    if ($('.ac_results:visible').length) {
      $popup.addClass('disabled');
    }
  });

  $main_search.on('click', function(e) {
    if ($(e.target).hasClass('main-search')) {
      $search.trigger('click').trigger('focus');
    }
  });

  $main_search.hover_delayed(function() {
    $main_search.addClass('hovered');
  }, function() {
    $main_search.removeClass('hovered');
  }, 250);
});

// конфигурация автодополнений
var searcheables = {
  animes: {
    title: 'Поиск по аниме...',
    autocomplete: '/animes/autocomplete/',
    phrase: '/animes/search/[phrase]',
    id: '/animes/[id]',
    regexp: /.*\/search\/(.*?)\/.*/
  },
  mangas: {
    title: 'Поиск по манге...',
    autocomplete: '/mangas/autocomplete/',
    phrase: '/mangas/search/[phrase]',
    id: '/mangas/[id]',
    regexp: /.*\/search\/(.*?)\/.*/
  },
  characters: {
    title: 'Поиск по персонажам...',
    autocomplete: '/characters/autocomplete/',
    phrase: '/characters/[phrase]',
    id: '/characters/[id]',
    regexp: /^\/characters\/(.*?)/
  },
  seyu: {
    title: 'Поиск по сейю...',
    autocomplete: '/people/autocomplete/seyu/',
    phrase: '/seyu/[phrase]',
    id: '/seyu/[id]',
    regexp: /^\/seyu\/(.*?)/
  },
  producer: {
    title: 'Поиск по режиссёрам...',
    autocomplete: '/people/autocomplete/producer/',
    phrase: '/producer/[phrase]',
    id: '/person/[id]',
    regexp: /^\/producer\/(.*?)/
  },
  mangaka: {
    title: 'Поиск по мангакам...',
    autocomplete: '/people/autocomplete/mangaka/',
    phrase: '/mangaka/[phrase]',
    id: '/person/[id]',
    regexp: /^\/mangaka\/(.*?)/
  },
  people: {
    title: 'Поиск по всем людям...',
    autocomplete: '/people/autocomplete/',
    phrase: '/people/[phrase]',
    id: '/person/[id]',
    regexp: /^\/people\/(.*?)/
  },
  users: {
    title: 'Поиск по пользователям...',
    autocomplete: '/users/autocomplete/',
    phrase: '/users/[phrase]',
    id: '/[id]',
    regexp: /^\/users\/(.*?)/
  }
};
