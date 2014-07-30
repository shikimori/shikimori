// кривые урлы с ouath фейсбука
if (location.hash == '#_=_') {
  location.hash = '';
}
// global button reset
$('button').live('click', function(e) {
  return false;
});
$(function() {
  $('.notifications.unread_count').tipsy({
    live: true,
    opacity: 1
  });

  // отображение flash сообщений от рельс
  $('p.flash-notice').each(function(k, v) {
    if (v.innerHTML.length) {
      $.flash({notice: v.innerHTML});
    }
  });
  $('p.flash-alert').each(function(k, v) {
    if (v.innerHTML.length) {
      $.flash({alert: v.innerHTML});
    }
  });
  // сворачиваение всех нужных блоков "свернуть"
  collapse_collapses($(document));

  process_current_dom();

  if (IS_LOGGED_IN) {
    window.faye_loader = new FayeLoader();
    faye_loader.apply();
  }

  $.form_navigate({size: 250, message: "Вы написали и не сохранили какой-то комментарий! Уверены, что хотите покинуть страницу?"});
});
$('.ajax,.slide>div').live('ajax:success', function() {
  process_current_dom();
});

// обработка элементов страницы (инициализация галерей, шрифтов, ссылок)
function process_current_dom() {
  // нормализуем ширину всех огромных картинок
  $('img.check-width').normalizeImage({
    'class': 'check-width',
    'fancybox': $.galleryOptions
  });

  // стена картинок
  $('.wall').shikiWall();

  // редакторы
  $('.shiki-editor').shikiEditor();

  // то, что должно превратиться в ссылки
  $('.linkeable').wrap(function() {
    var $this = $(this);
    $this.removeClass('linkeable').addClass('linkeable-processed');
    return '<a href="' + $this.data('href') + '" title="' + ($this.data('title') || $this.html()) + '" />';
  });

  // блоки, загружаемые аяксом
  $('.postloaded[data-href]').each(function() {
    var $this = $(this);
    if (!$this.is(':visible')) {
      return;
    }
    $this.load($this.data('href'), function() {
      $this.trigger('ajax:success');
    });
    $this.attr('data-href', null);
  });


  // инициализация подгружаемых тултипов
  $('.anime-tooltip')
    .tooltip(ANIME_TOOLTIP_OPTIONS)
    .removeClass('anime-tooltip');

  $('.bubbled')
    .addClass('bubbled-initialized')
    .removeClass('bubbled')
    .tooltip($.extend({offset: [-35, 10]}, tooltip_options));
}

// сворачиваение всех нужных блоков "свернуть"
function collapse_collapses($root) {
  _.each(($.cookie("collapses") || "").replace(/;$/, '').split(';'), function(v, k) {
    $('#collapse-'+v, $root).trigger('click', true);
  });
}

// сворачиваение всех нужных блоков "свернуть"
$('.ajax,.slide > .selected').live('ajax:success', function() {
  collapse_collapses($(this));
});

// click on history link
$('a[rel=history]').live('click', function(e) {
  if (in_new_tab(e)) {
    return;
  }
  History.pushState({timestamp: Date.now()}, null, this.href.replace(/^http:\/\/.*?\//, '/'));
  return false;
});

// ссылка "все"
//$('.related-all a,.related-all span.link, .subheadline a').live('click', function() {
$('.b-options-floated a, .subheadline a').live('click', function() {
  var $target = $(".slider-control a[href='"+(this.href || this.getAttribute('data-href'))+"']")
                  .add(".slider-control span.link[data-href='"+(this.href || this.getAttribute('data-href'))+"']");
  if (!$target.length) {
    return;
  }

  if ($(window).scrollTop() > 200) {
    $.scrollTo('h1');
  }
  $target.trigger('click');
  return false;
});

// fancybox видео блок
// TODO: засунуть инициализацию в process_current_dom
$(document.body).on('click', '.video', function(e) {
  // если это спан, то мы жмём на кнопочки
  if ($(e.target).tagName() == 'span') {
    return;
  }
  if (!$('a', this).data('fancybox')) {
    $('a', this).fancybox($(this).hasClass('vk') ? $.vkOptions : $.youtubeOptions);
    $('a', this).trigger('click');
  }
  if (!in_new_tab(e)) {
    return false;
  }
});

// открыта ли ссылка в новом табе?
function in_new_tab(e) {
  return (e.button == 1) || (e.button == 0 && (e.ctrlKey || e.metaKey));
}
// на мобильной ли мы версии (телефон)
function is_mobile() {
  return screen.width <= 480;
}
// на мобильной ли мы версии (планшет или ниже)
function is_tablet() {
  return screen.width <= 768;
}
// спецэкранирование некоторых символов поиска
function search_escape(phrase) {
  return (phrase || '').replace(/\+/g, '(l)')
      .replace(/ +/g, '+')
      .replace(/\\/g, '(b)')
      .replace(/\//g, '(s)')
      .replace(/\./g, '(d)')
      .replace(/%/g, '(p)');
}


var addthis_config = {
  ui_language: 'ru'
};

var I18N = {
  nickname: "Логин",
  subject: "Название",
  title: "Название",
  email: "E-mail",
  password: "Пароль",
  body: "Текст",
  created_at: "",
  forbidden: ""
};
