pageLoad('messages_index', () => {
  process();
  $('.l-page').on('postloader:success', process);
});

function process() {
  $('.item-request-confirm, .item-request-reject')
    .on('ajax:success', ({ currentTarget }) => {
      readMessage($(currentTarget).closest('.b-message'));
    });

  $('.item-request-reject.friend-request').on('click', ({ currentTarget }) => {
    readMessage($(currentTarget).closest('.b-message'));
  });
}

function readMessage($message) {
  const $appearMarker = $message
    .find('.b-appear_marker')
    .data({ disabled: false });

  $message.trigger('appear', [$appearMarker, true]);
  $message.find('.main-controls').children(':not(.item-delete)').remove();
  $message.find('.main-controls').children('.item-delete').show();
}
