import Turbolinks from 'turbolinks';
import TinyUri from 'tiny-uri';

pageLoad('profiles_comments', () =>
  $('form.comments-search').on('submit', e => {
    e.preventDefault();

    const $search = $(e.currentTarget).find('input.search');
    const url = new TinyUri($search.data('search_url'))
      .query.set('phrase', $search.val())
      .toString();

    Turbolinks.visit(url);
  })
);
