import axios from 'axios';

pageLoad('pages_oauth', () => {
  $('select#oauth_application_id, input[name="scopes[]"]').on('change', ({ currentTarget }) => {
    $('.l-page').addClass('b-ajax');
    $(currentTarget).closest('form').submit();
  });

  $('#request_acces_token').on('click', ({ currentTarget }) => {
    const $node = $(currentTarget);
    const $formatResponse = $('.access-token-response')
      .html('')
      .addClass('b-ajax')
      .show();

    axios
      .request({
        url: $node.data('token_url'),
        method: 'post',
        headers: {},
        data: {
          grant_type: 'authorization_code',
          client_id: $node.data('client_id'),
          client_secret: $node.data('client_secret'),
          code: $node.data('code'),
          redirect_uri: $node.data('redirect_uri')
        },
        responseType: 'json',
        validateStatus(status) {
          return ((status >= 200) && (status < 300)) || (status === 401);
        }
      })
      .then(request =>
        $formatResponse
          .removeClass('b-ajax')
          .html(formatResponse(JSON.stringify(request.data)))
          .process()).catch(error =>
        $formatResponse
          .removeClass('b-ajax')
          .html(formatResponse(error.toString()))
      );
  });

  $('#refresh_acces_token').on('click', ({ currentTarget }) => {
    const $node = $(currentTarget);
    const $refreshTokenResponse = $('.refresh-token-response')
      .html('')
      .addClass('b-ajax')
      .show();

    axios
      .request({
        url: $node.data('token_url'),
        method: 'post',
        headers: {},
        data: {
          grant_type: 'refresh_token',
          client_id: $node.data('client_id'),
          client_secret: $node.data('client_secret'),
          refresh_token: $node.data('refresh_token')
        },
        responseType: 'json',
        validateStatus(status) {
          return ((status >= 200) && (status < 300)) || (status === 401);
        }
      })
      .then(request =>
        $refreshTokenResponse
          .removeClass('b-ajax')
          .html(formatResponse(JSON.stringify(request.data)))
          .process()).catch(error =>
        $refreshTokenResponse
          .removeClass('b-ajax')
          .html(formatResponse(error.toString()))
      );
  });
});

function formatResponse(text) {
  return '<div class=\'to-process\' data-dynamic=\'code_highlight\'>' +
    '<code class=\'b-code-v2\' data-language=\'json\'>' +
      text +
    '</code>' +
  '</div>';
}
