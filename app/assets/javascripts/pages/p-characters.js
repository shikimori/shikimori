import FavouriteStar from 'views/application/favourite_star';
import ImageboardGallery from 'views/images/imageboard_gallery';

pageLoad('characters_show', () => {
  $('.text').checkHeight({ max_height: 200 });

  new FavouriteStar($('.b-subposter-actions .fav-add'), gon.is_favoured);

  $('.b-subposter-actions .new_comment').on('click', () => {
    const $editor = $('.b-form.new_comment textarea');
    $.scrollTo($editor, () => $editor.focus());
  });
});

pageLoad('characters_art', () => {
  new ImageboardGallery('.b-gallery');
});
pageLoad('characters_cosplay', () => {
  new Animes.Cosplay('.l-content');
});
