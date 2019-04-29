import delay from 'delay';
import Turbolinks from 'turbolinks';

pageLoad('users_similar', async () => {
  if ($('p.pending').exists()) {
    const url = document.location.href;
    await delay(5000);

    if (url === document.location.href) {
      Turbolinks.visit(document.location.href, true);
    }
  }
});
