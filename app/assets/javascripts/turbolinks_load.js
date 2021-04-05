import Turbolinks from 'turbolinks';
// import bowser from 'bowser';
import cookies from 'js-cookie';
import { flash } from 'shiki-utils';

$(document).on('turbolinks:load', () => {
  window.flash = flash;

  // document.body.classList.add(
  //   bowser.name.toLowerCase().replace(/ /g, '_')
  // );

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
  $('.b-list_switchers .switcher').on('click', ({ currentTarget }) => {
    cookies.set(
      $(currentTarget).data('name'),
      $(currentTarget).data('value'),
      { expires: 730, path: '/' }
    );
    Turbolinks.visit(document.location.href);
  });
});
