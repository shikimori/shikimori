if ('Highcharts' in window) {
  // чтобы даты в графиках highcharts были корректными
  Highcharts.setOptions({
    global: {
      useUTC: false
    }
  });

  // новые цвета
  var colors_old = _.clone(Highcharts.getOptions().colors);
  var colors_d3 = [ '#1f77b4', '#aec7e8', '#ff7f0e', '#ffbb78', '#2ca02c', '#98df8a', '#d62728', '#ff9896', '#9467bd', '#c5b0d5', '#8c564b', '#c49c94', '#e377c2', '#f7b6d2', '#7f7f7f', '#c7c7c7', '#bcbd22', '#dbdb8d', '#17becf', '#9edae5' ]
  var colors_hz = [ '#44bbff', '#c09eda', '#9bd51f', '#f7b42c', '#f27490', '#fc575e', '#f27624', '#90d5ec', '#f49ac1', '#ca5', '#b5e4f2', '#9ab' ];

  Highcharts.getOptions().colors.length = 0;
  //var colors = [ '#4682b4', '#2ca02c', '#d65757', '#db843d', '#a47d7c', '#bcbd22', '#ff9896', '#f7b42c', '#80699b', '#c5b0d5' ].concat(colors_hz);
  var colors = [].concat(colors_hz);

  for (var index in colors) {
    Highcharts.getOptions().colors.push(colors[index]);
  }

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
