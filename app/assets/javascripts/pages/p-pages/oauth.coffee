import axios from 'axios'

pageLoad 'pages_oauth', ->
  $('select#oauth_application_id').on 'change', ->
    $('.l-page').addClass('b-ajax')
    $(@).closest('form').submit()

  $('#request_acces_token').on 'click', ->
    $node = $(@)
    $format_response = $('.access-token-response')
      .html('')
      .addClass('b-ajax')
      .show()

    axios
      .request(
        url: $node.data('token_url')
        method: 'post'
        headers: {}
        data:
          grant_type: 'authorization_code'
          client_id: $node.data('client_id')
          client_secret: $node.data('client_secret')
          code: $node.data('code')
          redirect_uri: $node.data('redirect_uri')
        responseType: 'json'
        validateStatus: (status) ->
          (status >= 200 && status < 300) || status == 401
      )
      .then (request) ->
        $format_response
          .removeClass('b-ajax')
          .html(format_response(JSON.stringify(request.data)))
          .process()

      .catch (error) ->
        $format_response
          .removeClass('b-ajax')
          .html(format_response(error.toString()))

  $('#refresh_acces_token').on 'click', ->
    $node = $(@)
    $refresh_token_response = $('.refresh-token-response')
      .html('')
      .addClass('b-ajax')
      .show()

    axios
      .request(
        url: $node.data('token_url')
        method: 'post'
        headers: {}
        data:
          grant_type: 'refresh_token'
          client_id: $node.data('client_id')
          client_secret: $node.data('client_secret')
          refresh_token: $node.data('refresh_token')
        responseType: 'json'
        validateStatus: (status) ->
          (status >= 200 && status < 300) || status == 401
      )
      .then (request) ->
        $refresh_token_response
          .removeClass('b-ajax')
          .html(format_response(JSON.stringify(request.data)))
          .process()

      .catch (error) ->
        $refresh_token_response
          .removeClass('b-ajax')
          .html(format_response(error.toString()))

format_response = (text) ->
  "<div class='to-process' data-dynamic='code_highlight'>" +
    "<code class='b-code' data-language='json'>" +
      text +
    '</code>' +
  '</div>'
