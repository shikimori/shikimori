import Turbolinks from 'turbolinks';
import URI from 'urijs';

pageLoad('profiles_comments', () =>
  $('form.comments-search').on('submit', e => {
    e.preventDefault();

    const $search = $(e.currentTarget).find('input.search');
    const url = URI($search.data('search_url'))
      .addQuery({ search: $search.val() });

    Turbolinks.visit(url);
  })
);
