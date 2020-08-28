import ImageboardGallery from 'views/images/imageboard_gallery';

pageLoad('characters_show', async () => {
  $('.text').checkHeight({ max_height: 200 });

  $('.b-subposter-actions .new_comment').on('click', () => {
    const $editor = $('.b-form.new_comment textarea');
    $.scrollTo($editor, () => $editor.focus());
  });

  const [{ FavoriteStar }, { LangTrigger }] = await Promise.all([
    import(/* webpackChunkName: "db_entries_show" */ 'views/db_entries/favorite_star'),
    import(/* webpackChunkName: "db_entries_show" */ 'views/db_entries/lang_trigger')
  ])

  new LangTrigger('.b-lang_trigger');
  new FavoriteStar($('.b-subposter-actions .fav-add'), gon.is_favoured);
});

pageLoad('characters_art', () => {
  new ImageboardGallery('.b-gallery');
});
pageLoad('characters_cosplay', () => {
  new Animes.Cosplay('.l-content');
});
