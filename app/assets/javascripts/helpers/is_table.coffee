module.exports = window.is_tablet = ->
  !!window.mobile_detect.tablet() || screen.width <= 768
