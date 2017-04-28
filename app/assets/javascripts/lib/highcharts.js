if ('Highcharts' in window) {
  if (false) {
    $('.page-content').prepend('<div id="colors" style="float: left; margin-right: 20px;"></div><div id="colors_old" style="float: left; margin-right: 20px;"></div><div id="colors_d3" style="float: left; margin-right: 20px;"></div><div id="colors_hz" style="float: left; margin-right: 20px;"></div>')
    for (var index in colors) {
      $('#colors').append('<div style="width: 200px; height: 30px; background-color: '+colors[index]+';"></div>')
    }
    for (var index in colors_d3) {
      $('#colors_d3').append('<div style="width: 200px; height: 30px; background-color: '+colors_d3[index]+';"></div>')
    }
    for (var index in colors_old) {
      $('#colors_old').append('<div style="width: 200px; height: 30px; background-color: '+colors_old[index]+';"></div>')
    }
    for (var index in colors_hz) {
      $('#colors_hz').append('<div style="width: 200px; height: 30px; background-color: '+colors_hz[index]+';"></div>')
    }
  }
}
