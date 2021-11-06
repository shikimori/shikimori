import cookies from 'js-cookie';

pageLoad('age_restricted', () =>
  $('.b-age_restricted .confirm').on('click', () => {
    cookies.set(
      $('.confirm').data('cookie'),
      true,
      { expires: 9999, path: '/' }
    );

    window.location.reload();
  })
);
