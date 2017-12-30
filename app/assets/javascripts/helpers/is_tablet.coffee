module.exports = window.is_tablet = ->
  !!window.mobile_detect.tablet() || document.documentElement.clientWidth <= 768
