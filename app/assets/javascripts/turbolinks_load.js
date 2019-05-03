import Turbolinks from 'turbolinks';
import bowser from 'bowser';
import flash from 'services/flash';

$(document).on('turbolinks:load', () => {
  document.body.classList.add(
    bowser.name.toLowerCase().replace(/ /g, '_')
  );

  $('p.flash-notice').each((k, v) => {
    if (v.innerHTML.length) { flash.notice(v.innerHTML); }
  });

  $('p.flash-alert').each((k, v) => {
    if (v.innerHTML.length) {
      flash.error(v.innerHTML);
    }
  });

  $(document.body).process();

  // переключатели видов отображения списка
  $('.b-list_switchers .switcher').on('click', function () {
    $.cookie($(this).data('name'), $(this).data('value'), { expires: 730, path: '/' });
    Turbolinks.visit(document.location.href);
  });
});
