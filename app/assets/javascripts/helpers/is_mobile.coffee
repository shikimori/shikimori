module.exports = window.is_mobile = ->
  !!window.mobile_detect.mobile() || screen.width <= 480
