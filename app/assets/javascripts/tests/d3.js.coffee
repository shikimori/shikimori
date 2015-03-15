#= require jquery
#= require core/sugar
#= require d3

$ ->
  d3.json "#{$(document.body).data('anime_id')}/data.json", (error, data) ->
    new Chronology(data).render()

class @Chronology
  constructor: (data) ->
    @graph = data
    @_prepare_data()
    @_prepare_d3()

  # базовые константы
  _prepare_data: ->
    @max_weight = @graph.links.map((v) -> v.weight).max() * 1.0
    original_size = @graph.nodes.length
    size_scale = (original_size - @max_weight) / original_size

    @size = if size_scale < 0.5
      # актуально для naruto (20) и detective conan (235)
      original_size * @_scale(size_scale, 0.4, 0.6, 0.5)
    else
      original_size

    console.log "nodes: #{@size} (#{original_size}), max_weight: #{@max_weight}, size_scale: #{size_scale}"

    # изображение
    @image_width = 48
    @image_height = 75

    @radius = [@image_width, @image_height].max() / 2.0 + 5

    @image_x_offset = @image_width / 2 + 5
    @images_y_offset = @image_height / 2 + 5

    # вся область
    @width = if @size < 30
      @_scale @size, 320, 1300
    else
      @_scale @size, 1300, 2000, 100
    @height = @width

  # d3 объекты
  _prepare_d3: ->
    # математический объект для обсчёта координат
    @d3_force = d3.layout.force()
      .charge(-2000)
      .friction 0.7
      .linkDistance (d) =>
        distance = 300
        weight = d.weight / @max_weight
        @_scale distance * weight, 40, 300, 300

      .size([@width, @height])
      .nodes(@graph.nodes)
      .links(@graph.links)


    # масштабрирование x в интервале [min,max] в долях от max_x
  _scale: (x, min, max, max_x = 30) ->
    percent = Math.min(x,max_x) * 1.0 / max_x
    min + (max - min) * percent

  # ограничение x координаты по ширине рабочей зоны
  _bounded_x: (x) =>
    Math.max(@radius, Math.min(@width - @radius, x))

  # ограничение y координаты по высоте рабочей зоны
  _bounded_y: (y) =>
    Math.max(@radius, Math.min(@height - @radius, y))

  render: ->
    # svg тег
    svg = d3.select('body')
      .append('svg')
      .attr
        width: @width
        height: @height

    # начинаем рисовать
    @d3_force.start()

    # линии
    link = svg.selectAll('.link')
      .data(@graph.links)
      .enter()
        .append('line')
          .attr
            class: 'link'
            #x1: @width / 2 - @image_x_offset
            #x2: @width / 2 - @image_x_offset
            #y1: @height / 2 - @image_x_offset
            #y2: @height / 2 - @image_x_offset

    # картинки
    node = svg.selectAll('.node')
      .data(@graph.nodes)
      .enter()
        .append('g')
        .attr
          class: 'node'
          #transform: "translate(#{@width / 2 - @image_x_offset}, #{@height / 2 - @image_x_offset})"
        .call(@d3_force.drag)

    node.append('svg:image')
      .attr
        class: 'node'
        width: @image_width
        height: @image_height
        'xlink:href': (d) -> d.image_url

    #node.append('title').text (d) -> d.name

    # обсчёт координат объектов
    @d3_force.on 'tick', =>
      node.attr
        transform: (d) =>
          "translate(#{@_bounded_x(d.x) - @image_x_offset}, #{@_bounded_y(d.y) - @images_y_offset})"

      link.attr
        x1: (d) => @_bounded_x(d.source.x)
        y1: (d) => @_bounded_y(d.source.y)
        x2: (d) => @_bounded_x(d.target.x)
        y2: (d) => @_bounded_y(d.target.y)

      node.each(@_collide(0.5))

  # функцция для обсчёта коллизий
  _collide: (alpha) =>
    quadtree = d3.geom.quadtree(@graph.nodes)

    (d) =>
      rb = 2 * @radius
      nx1 = d.x - rb
      nx2 = d.x + rb
      ny1 = d.y - rb
      ny2 = d.y + rb

      quadtree.visit (quad, x1, y1, x2, y2) =>
        if quad.point && quad.point != d
          x = d.x - quad.point.x
          y = d.y - quad.point.y
          l = Math.sqrt(x * x + y * y)

          if l < rb
            l = (l - rb) / l * alpha

            x *= l
            y *= l

            d.x = @_bounded_x(d.x - x)
            d.y = @_bounded_y(d.y - y)
            quad.point.x = @_bounded_x(quad.point.x + x)
            quad.point.y = @_bounded_y(quad.point.y + y)

        x1 > nx2 || x2 < nx1 || y1 > ny2 || y2 < ny1
