(($) ->
  param = $('meta[name=csrf-param]').attr 'content'
  token = $('meta[name=csrf-token]').attr 'content'

  post = {}
  post[param] = token
  headers =
    'X-CSRF-Token': token

  window.CSRF =
    post: post
    headers: headers
)(jQuery)
