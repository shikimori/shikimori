import delay from 'delay';
import Turbolinks from 'turbolinks';

page_load('users_similar', async () => {
  // если страница ещё не готова, перегрузимся через 5 секунд
  if ($('p.pending').exists()) {
    const url = document.location.href;
    await delay(5000);

    if (url === document.location.href) {
      Turbolinks.visit(document.location.href, true);
    }
  }
});
