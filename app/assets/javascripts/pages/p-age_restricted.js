import cookies from 'js-cookie';

pageLoad('age_restricted', () =>
  $('.confirm').click(() => {
    cookies.set(
      $('.confirm').data('cookie'),
      true,
      { expires: 9999, path: '/' }
    );

    window.location.reload();
  })
);
