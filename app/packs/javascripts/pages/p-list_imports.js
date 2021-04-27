import delay from 'delay';
import Turbolinks from 'turbolinks';

pageLoad('list_imports_show', async () => {
  // если страница ещё не готова, перегрузимся через 5 секунд
  if ($('.b-nothing_here').exists()) {
    const url = document.location.href;
    await delay(5000);

    if (url === document.location.href) {
      Turbolinks.visit(document.location.href);
    }
  }

  // сворачиваем все списки
  $('.b-options-floated.collapse .action').click();
});
