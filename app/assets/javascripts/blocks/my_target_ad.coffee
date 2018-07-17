getjs = require('get-js')

$(document).on 'page:load', ->
  return if document.body.id == 'pages_my_target_ad'
  return unless ENV == 'production'
  return unless mobile_detect.phone() || mobile_detect.tablet()
  return unless URI(location.href).domain() == 'shikimori.org'

  if window.MRGtag
    window.MRGtag.push({})
  else
    getjs('//ad.mail.ru/static/ads-async.js').then ->
      (window.MRGtag = window.MRGtag || []).push({})
