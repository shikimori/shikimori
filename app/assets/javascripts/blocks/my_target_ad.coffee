$(document).one 'page:load', ->
  return unless ENV == 'production'
  return unless mobile_detect.phone() || mobile_detect.tablet()
  return unless URI(location.href).domain == 'shikimori.org'

  window.mailru_ad_client = "ad-99070"
  window.mailru_ad_slot = 99070
  $(document.body).append('<script type="text/javascript" src="//rs.mail.ru/static/ads-min.js"></script>')
