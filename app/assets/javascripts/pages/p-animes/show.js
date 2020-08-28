import FavoriteStar from 'views/application/favorite_star';

pageLoad('animes_show', 'mangas_show', 'ranobe_show', () => {
  $('.b-notice').tipsy({ gravity: 's' });
  $('.c-screenshot').magnificRelGallery();

  $('.text').checkHeight({ max_height: 200 });

  new FavoriteStar($('.b-subposter-actions .fav-add'), gon.is_favoured);

  const $newReview = $('.new_review');
  if (window.SHIKI_USER.isSignedIn) {
    const newReviewUrl = $newReview
      .attr('href')
      .replace(/%5Buser_id%5D=(\d+|ID)/, `%5Buser_id%5D=${window.SHIKI_USER.id}`);
    $newReview.attr({ href: newReviewUrl });
  } else {
    $newReview.hide();
  }

  // autoload of resource info for guests
  $('.l-content').on('postloaded:success', '.resources-loader', () => (
    $('.c-screenshot').magnificRelGallery()
  ));

  $('.other-names').on('clickloaded:success', ({ currentTarget }, data) => {
    $(currentTarget).closest('.line').replaceWith(data);
  });

  $('.b-subposter-actions .new_comment').on('click', () => {
    const $editor = $('.b-form.new_comment textarea');
    $.scrollTo($editor, () => $editor.focus());
  });

  import(/* webpackChunkName: "dbentry_show" */ 'views/animes/lang_trigger')
    .then(({ LangTrigger }) => {
      new LangTrigger('.b-lang_trigger')
    })
});
