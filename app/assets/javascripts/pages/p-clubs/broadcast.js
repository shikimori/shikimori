import Turbolinks from 'turbolinks';

pageLoad('.clubs-broadcast', () => {
  $('.b-form.new_comment').on('ajax:success', ({ currentTarget }, comment) => {
    const nextUrl = $(currentTarget).data('next-url') + '#comment-' + comment.id;
    Turbolinks.visit(nextUrl);
  });
});
