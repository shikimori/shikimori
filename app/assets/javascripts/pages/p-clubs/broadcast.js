import Turbolinks from 'turbolinks';
import ShikiEditor from 'views/shiki_editor';

pageLoad('.clubs-broadcast', () => {
  new ShikiEditor('.b-shiki_editor');

  $('.new_broadcast').on('ajax:success', (e, comment) => {
    const nextUrl = $('.new_broadcast').data('next_url') + '#comment-' + comment.id;
    Turbolinks.visit(nextUrl);
  });
});
