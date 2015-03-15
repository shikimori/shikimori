#= require jquery
#= require core/sugar
#= require d3

$ ->
  d3.json "#{$(document.body).data('anime_id')}/data.json", render

render = (error, graph) ->
  # масштабрирование x в интервале [min,max] в долях от max_x
  scale = (x, min, max, max_x = 30) ->
    percent = Math.min(x,max_x) * 1.0 / max_x
    min + (max - min) * percent

  bound_x = (x) -> Math.max(radius, Math.min(width - radius, x))
  bound_y = (y) -> Math.max(radius, Math.min(height - radius, y))

  # базовые константы
  max_weight = graph.links.map((v) -> v.weight).max() * 1.0
  original_size = graph.nodes.length
  size_scale = (original_size - max_weight) / original_size

  size = if size_scale < 0.5
    # актуально для naruto (20) и detective conan (235)
    original_size * scale(size_scale, 0.4, 0.6, 0.5)
  else
    original_size

  console.log "nodes: #{size} (#{original_size}), max_weight: #{max_weight}, size_scale: #{size_scale}"

  width = if size < 30 then scale(size, 320, 1300) else scale(size, 1300, 2000, 100)
  height = width

  image_width = 48
  image_height = 75

  radius = [image_width, image_height].max() / 2.0 + 5
  x_off = image_width / 2 + 5
  y_off = image_height / 2 + 5

  # математический объект для обсчёта координат
  force = d3.layout.force()
    .charge(-2000)
    .friction 0.7
    .linkDistance (d) ->
      distance = 300
      weight = d.weight / max_weight
      scale distance * weight, 40, 300, 300

    .size([width, height])

  #color = d3.scale.category20()

  # svg тег
  svg = d3.select('body')
    .append('svg')
    .attr
      width: width
      height: height

  # начинаем рисовать
  force
    .nodes(graph.nodes)
    .links(graph.links)
    .start()

  # линии
  link = svg.selectAll('.link')
    .data(graph.links)
    .enter()
      .append('line')
        .attr(class: 'link')

  # картинки
  node = svg.selectAll('.node')
    .data(graph.nodes)
    .enter()
      .append('g')
      .attr
        class: 'node'
        #r: 75
      #.style
        #fill: (d) -> color d.group
      .call(force.drag)

  node.append('svg:image')
    .attr
      class: 'node'
      width: image_width
      height: image_height
      'xlink:href': (d) -> d.image_url

  #node.append('title').text (d) -> d.name

  # обсчёт координат объектов
  force.on 'tick', ->
    node.attr
      transform: (d) ->
        "translate(#{bound_x(d.x) - x_off}, #{bound_y(d.y) - y_off})"

    link.attr
      x1: (d) -> bound_x(d.source.x)
      y1: (d) -> bound_y(d.source.y)
      x2: (d) -> bound_x(d.target.x)
      y2: (d) -> bound_y(d.target.y)

    node.each(collide(0.5))

  # функцция для обсчёта коллизий
  collide = (alpha) ->
    quadtree = d3.geom.quadtree(graph.nodes)

    (d) ->
      rb = 2 * radius
      nx1 = d.x - rb
      nx2 = d.x + rb
      ny1 = d.y - rb
      ny2 = d.y + rb

      quadtree.visit (quad, x1, y1, x2, y2) ->
        if quad.point && quad.point != d
          x = d.x - quad.point.x
          y = d.y - quad.point.y
          l = Math.sqrt(x * x + y * y)

          if l < rb
            l = (l - rb) / l * alpha

            x *= l
            y *= l

            d.x = bound_x(d.x - x)
            d.y = bound_y(d.y - y)
            quad.point.x = bound_x(quad.point.x + x)
            quad.point.y = bound_y(quad.point.y + y)

        x1 > nx2 || x2 < nx1 || y1 > ny2 || y2 < ny1
