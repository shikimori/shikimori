import delay from 'delay';

pageLoad('tests_achievements_notification', async () => {
  $('.b-button').on('click', ({ currentTarget }) => {
    const $button = $(currentTarget);
    const data = JSON.parse($button.prev().children('textarea').val());
    window.SHIKI_ACHIEVEMENTS_NOTIFIER.notify(data);
  });

  await delay();
  $('.b-button').click();
});
