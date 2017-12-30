module.exports = window.is_mobile = ->
  !!window.mobile_detect.mobile() || document.documentElement.clientWidth <= 480
