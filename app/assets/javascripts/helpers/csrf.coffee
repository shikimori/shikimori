module.exports = ->
  param = $('meta[name=csrf-param]').attr 'content'
  token = $('meta[name=csrf-token]').attr 'content'

  post = {}
  post[param] = token
  headers =
    'X-CSRF-Token': token

  {
    post: post
    headers: headers
  }
