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

  $.form_navigate({size: 250, message: "Вы написали и не сохранили какой-то большой комментарий! Уверены, что хотите покинуть страницу?"});
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
    $this.removeClass('linkeable');
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
  $('.bubbled').addClass('bubbled-initialized').removeClass('bubbled').tooltip($.extend({offset: [-35, 10]}, tooltip_options));
  $('.bubbled-image').addClass('bubbled-initialized').removeClass('bubbled-image').tooltip($.extend({}, tooltip_options));
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
  $.history.load(this.href.replace(/^http:\/\/.*?\//, '/'));
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

// чтобы даты в графиках highcharts были корректными
Highcharts.setOptions({
  global: {
    useUTC: false
  }
});

// новые цвета
var colors_old = _.clone(Highcharts.getOptions().colors);
var colors_d3 = [ '#1f77b4', '#aec7e8', '#ff7f0e', '#ffbb78', '#2ca02c', '#98df8a', '#d62728', '#ff9896', '#9467bd', '#c5b0d5', '#8c564b', '#c49c94', '#e377c2', '#f7b6d2', '#7f7f7f', '#c7c7c7', '#bcbd22', '#dbdb8d', '#17becf', '#9edae5' ]
var colors_hz = [ '#44bbff', '#c09eda', '#9bd51f', '#f7b42c', '#f27490', '#fc575e', '#f27624', '#90d5ec', '#f49ac1', '#ca5', '#b5e4f2', '#9ab' ];

Highcharts.getOptions().colors.length = 0;
//var colors = [ '#4682b4', '#2ca02c', '#d65757', '#db843d', '#a47d7c', '#bcbd22', '#ff9896', '#f7b42c', '#80699b', '#c5b0d5' ].concat(colors_hz);
var colors = [].concat(colors_hz);

for (var index in colors) {
  Highcharts.getOptions().colors.push(colors[index]);
}

if (false) {
  $('.page-content').prepend('<div id="colors" style="float: left; margin-right: 20px;"></div><div id="colors_old" style="float: left; margin-right: 20px;"></div><div id="colors_d3" style="float: left; margin-right: 20px;"></div><div id="colors_hz" style="float: left; margin-right: 20px;"></div>')
  for (var index in colors) {
    $('#colors').append('<div style="width: 200px; height: 30px; background-color: '+colors[index]+';"></div>')
  }
  for (var index in colors_d3) {
    $('#colors_d3').append('<div style="width: 200px; height: 30px; background-color: '+colors_d3[index]+';"></div>')
  }
  for (var index in colors_old) {
    $('#colors_old').append('<div style="width: 200px; height: 30px; background-color: '+colors_old[index]+';"></div>')
  }
  for (var index in colors_hz) {
    $('#colors_hz').append('<div style="width: 200px; height: 30px; background-color: '+colors_hz[index]+';"></div>')
  }
}

var TOOLTIP_TEMPLATE = '<div><div class="tooltip-inner"><div class="tooltip-arrow"></div><div class="clearfix"><div class="close"></div><a class="link"></a><div class="tooltip-details"><div class="ajax-loading" title="Загрузка..." /></div></div><div class="dropshadow-top"></div><div class="dropshadow-top-right"></div><div class="dropshadow-right"></div><div class="dropshadow-bottom-right"></div><div class="dropshadow-bottom"></div><div class="dropshadow-bottom-left"></div><div class="dropshadow-left"></div><div class="dropshadow-top-left"></div></div></div>';

var ANIME_TOOLTIP_OPTIONS = {
  position: 'top right',
  offset: [-4, 28, -10],
  relative: true,
  predelay: 300,
  delay: 50
};
