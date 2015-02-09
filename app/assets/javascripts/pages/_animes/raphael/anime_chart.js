Raphael.fn.drawGrid = function (x, y, width, height, wv, hv, color) {
  color = color || "#000";
  var path = ["M", Math.round(x) + .5,
              Math.round(y) + .5, "L",
              Math.round(x + width) + .5,
              Math.round(y) + .5,
              Math.round(x + width) + .5,
              Math.round(y + height) + .5,
              Math.round(x) + .5,
              Math.round(y + height) + .5,
              Math.round(x) + .5,
              Math.round(y) + .5],

    rowHeight = height / hv,
    columnWidth = width / wv;
  for (var i = 1; i < hv; i++) {
    path = path.concat(["M", Math.round(x) + .5, Math.round(y + i * rowHeight) + .5, "H", Math.round(x + width) + .5]);
  }
  for (i = 1; i < wv; i++) {
    path = path.concat(["M", Math.round(x + i * columnWidth) + .5, Math.round(y) + .5, "V", Math.round(y + height) + .5]);
  }
  return this.path(path.join(",")).attr({stroke: color});
};

Raphael.fn.drawScore = function (x, y, width, height, score) {
  var path = ["M", (width-x)*score/9-4, y-4, "L",
              (width-x)*score/9, y,
              (width-x)*score/9+4, y-4,
              (width-x)*score/9, y,
              (width-x)*score/9, y + height+2,
              (width-x)*score/9-4, y + height+2+4,
              (width-x)*score/9, y + height+2,
              (width-x)*score/9+4, y + height+2+4
             ];
  return this.path(path.join(","))
               .attr({stroke: "#FF9231", 'stroke-width': 2});
};


function getAnchors(p1x, p1y, p2x, p2y, p3x, p3y) {
  var l1 = (p2x - p1x) / 2,
      l2 = (p3x - p2x) / 2,
      a = Math.atan((p2x - p1x) / Math.abs(p2y - p1y)),
      b = Math.atan((p3x - p2x) / Math.abs(p2y - p3y));
  a = p1y < p2y ? Math.PI - a : a;
  b = p3y < p2y ? Math.PI - b : b;
  var alpha = Math.PI / 2 - ((a + b) % (Math.PI * 2)) / 2,
      dx1 = l1 * Math.sin(alpha + a),
      dy1 = l1 * Math.cos(alpha + a),
      dx2 = l2 * Math.sin(alpha + b),
      dy2 = l2 * Math.cos(alpha + b);
  return {
      x1: p2x - dx1,
      y1: p2y + dy1,
      x2: p2x + dx2,
      y2: p2y + dy2
  };
}

function humanize_hits(num) {
  if (num % 10 == 1) {
    return "голос";
  }
  if (num % 10 > 1 && num % 10 < 5) {
    return "голоса";
  }
  return "голосов";
}

function init_charts(chart_name) {
  // Grab the data
  var labels = [],
      data = [];
  $("#" + chart_name + "-data tfoot th").each(function () {
      labels.push($(this).html());
  });
  $("#" + chart_name + "-data tbody td").each(function () {
      data.push($(this).html());
  });

  var score = parseFloat($("#" + chart_name + "-score").html());

  // Draw
  var width = 775,
      height = 250,
      leftgutter = 0,
      bottomgutter = 20,
      topgutter = 20,
      colorhue = .6 || Math.random(),
      color = "hsb(" + [colorhue, .5, 1] + ")",
      r = Raphael(chart_name + "-chart", width, height),
      txt = {font: '12px Helvetica, Arial', fill: "#333333"},
      txt1 = {font: '10px Helvetica, Arial', fill: "#333333"},
      txt2 = {font: '12px Helvetica, Arial', fill: "#000000"},
      txt_tooltip = {font: '12px Helvetica, Arial', fill: "#333333"},
      X = (width - leftgutter) / labels.length,
      max = Math.max.apply(Math, data)/0.95,
      Y = (height - bottomgutter - topgutter) / max;

  // Grid
  r.drawGrid(leftgutter + X * .5 + .5, topgutter + .5, width - leftgutter - X, height - topgutter - bottomgutter, 9, 10, "#EEEEEE");

  // Score
  var scoreBlock = r.drawScore(leftgutter + X * .5 + .5, topgutter + .5, width - leftgutter - X, height - topgutter - bottomgutter, score);

  // Curve
  var path = r.path().attr({stroke: color, "stroke-width": 4, "stroke-linejoin": "round"}),
      bgp = r.path().attr({stroke: "none", opacity: .3, fill: color}),
      label = r.set(),
      is_label_visible = false,
      leave_timer,
      blanket = r.set();
  label.push(r.text(60, 12, "24 hits").attr(txt_tooltip));
  label.push(r.text(60, 27, "22 September 2008").attr(txt1).attr({fill: color}));
  label.hide();
  var frame = r.popup(100, 100, label, "right")
                 .attr({fill: "#FFFFFF", stroke: "#000000", "stroke-width": $.browser.mozilla ? 1 : 0.1, "fill-opacity": 1.0})
                 .hide();

  var p, bgpp;
  for (var i = 0, ii = labels.length; i < ii; i++) {
    var y = Math.round(height - bottomgutter - Y * data[i]),
        x = Math.round(leftgutter + X * (i + .5)),
        t = r.text(x, height - 6, labels[i]).attr(txt).toBack();
    if (!i) {
      p = ["M", x, y, "C", x, y];
      bgpp = ["M", leftgutter + X * .5, height - bottomgutter + 1, "L", x, y+1, "C", x, y];
    }
    if (i && i < ii - 1) {
      var Y0 = Math.round(height - bottomgutter - Y * data[i - 1]),
          X0 = Math.round(leftgutter + X * (i - .5)),
          Y2 = Math.round(height - bottomgutter - Y * data[i + 1]),
          X2 = Math.round(leftgutter + X * (i + 1.5));
      var a = getAnchors(X0, Y0, x, y, X2, Y2);
      p = p.concat([a.x1, a.y1, x, y, a.x2, a.y2]);
      bgpp = bgpp.concat([a.x1, a.y1, x, y, a.x2, a.y2]);
    }
    var dot = r.circle(x, y, 4).attr({fill: "#FFFFFF", stroke: color, "stroke-width": 2});
    blanket.push(r.rect(leftgutter + X * i, 0, X, height - bottomgutter).attr({stroke: "none", fill: "red", opacity: 0}));
    var rect = blanket[blanket.length - 1];

    // тултип
    if (!$.browser.opera) {
      (function (x, y, data, lbl, dot) {
        var timer, i = 0;
        rect.hover(function () {
          clearTimeout(leave_timer);
          var side = "right";
          if (x + frame.getBBox().width + 40 > width) {
            side = "left";
          }
          var ppp = r.popup(x, y, label, side, 1);
          frame.show().stop().animate({path: ppp.path}, 200 * is_label_visible);
          label[0].attr({text: data + " " + humanize_hits(data)}).show().stop().animateWith(frame, {translation: [ppp.dx, ppp.dy]}, 200 * is_label_visible);
          label[1].attr({text: "с оценкой " + lbl}).show().stop().animateWith(frame, {translation: [ppp.dx, ppp.dy]}, 200 * is_label_visible);
          dot.attr("r", 6);
          is_label_visible = true;
        }, function () {
          dot.attr("r", 4);
          leave_timer = setTimeout(function () {
            frame.hide();
            label[0].hide();
            label[1].hide();
            is_label_visible = false;
          }, 1);
        });
      })(x, y, data[i], labels[i], dot);
    }
  }
  p = p.concat([x, y, x, y]);
  bgpp = bgpp.concat([x+1, y, x+1, y, "L", x+1, height - bottomgutter + 1, "z"]);
  path.attr({path: p});
  bgp.attr({path: bgpp});
  scoreBlock.toFront();
  frame.toFront();
  label[0].toFront();
  label[1].toFront();
  blanket.toFront();
}
