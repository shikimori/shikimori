// кривые урлы с ouath фейсбука
if (location.hash == '#_=_') {
  location.hash = '';
}

// открыта ли ссылка в новом табе?
function in_new_tab(e) {
  return (e.button == 1) || (e.button == 0 && (e.ctrlKey || e.metaKey));
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
