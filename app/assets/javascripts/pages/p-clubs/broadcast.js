import Turbolinks from 'turbolinks';

pageLoad('.clubs-broadcast', () => {
  $('.new_broadcast').on('ajax:success', (e, comment) => {
    const nextUrl = $('.new_broadcast').data('next_url') + '#comment-' + comment.id;
    Turbolinks.visit(nextUrl);
  });
});
