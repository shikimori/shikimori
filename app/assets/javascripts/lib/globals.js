// кривые урлы с ouath фейсбука
if (location.hash == '#_=_') {
  location.hash = '';
}
// global button reset
$('button').live('click', function(e) {
  return false;
});
$('.ajax,.slide>div').live('ajax:success', function() {
  process_current_dom();
});

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
