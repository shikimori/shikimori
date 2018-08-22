import delay from 'delay';

$(() =>
  $(window).on('resize:debounced', () =>
    $('.packery').each(async function () {
      const packery = $(this).data('packery');

      packery.layout();
      await delay(1250);
      packery.layout();
    })
  )
);
