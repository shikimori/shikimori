class @ChronologyImages
  START_MARKERS = ['prequel']
  END_MARKERS = ['sequel']

  constructor: (data) ->
    @graph = data

    @_prepare_data()
    @_position_nodes()
    @_prepare_d3()

  # базовые константы
  _prepare_data: ->
    @max_weight = @graph.links.map((v) -> v.weight).max() * 1.0
    original_size = @graph.nodes.length
    size_scale = (original_size - @max_weight) / original_size

    @size = if size_scale < 0.5
      # актуально для naruto (20) и detective conan (235)
      original_size * @_scale(size_scale, from_min: 0, from_max: 0.5, to_min: 0.4, to_max: 0.6)
    else
      original_size

    console.log "nodes: #{@size} (#{original_size}), max_weight: #{@max_weight}, size_scale: #{size_scale}"

    # изображение
    @image_w = 48
    @image_h = 75

    @r = [@image_w, @image_h].max() / 2.0 + 5

    @rx = @image_w / 2.0
    @ry = @image_h / 2.0

    # вся область
    @w = if @size < 30
      @_scale @size,
        from_min: 0
        from_max: 30
        to_min: 480
        to_max: 1300
    else
      @_scale @size,
        from_min: 0
        from_max: 100
        to_min: 1300
        to_max: 2000
    @h = @w

    # даты
    @min_date = @graph.nodes.map((v) -> v.date).min() * 1.0
    @max_date = @graph.nodes.map((v) -> v.date).max() * 1.0

  # начальное позиционирование узлов
  _position_nodes: ->
    @graph.nodes.each (d) =>
      d.y = @_y_by_date(d.date)
      d.x = @w / 2.0 - @rx

      if d.date == @min_date
        d.fixed = true
        # смещение пропорционально количеству связей
        d.y += @_scale d.weight, from_min: 4, from_max: 9, to_min: 0, to_max: 175

      if d.date == @max_date
        d.fixed = true
        d.y -= 20
        # смещение пропорционально количеству связей
        d.y -= @_scale d.weight, from_min: 4, from_max: 9, to_min: 0, to_max: 150

  # d3 объекты
  _prepare_d3: ->
    # математический объект для обсчёта координат
    @d3_force = d3.layout.force()
      .charge(-2000)
      .friction 0.7
      .linkDistance (d) =>
        max_width = if @max_weight < 3
          @_scale @size, from_min: 2, from_max: 6, to_min: 100, to_max: 300
        else
          300

        @_scale 300 * (d.weight / @max_weight),
          from_min: 0
          from_max: 300
          to_min: 90
          to_max: max_width

      .size([@w, @h])
      .nodes(@graph.nodes)
      .links(@graph.links)

  # масштабрирование x в интервале [min,max] в долях от max_x
  _scale: (x, opt) ->
    percent = (x - opt.from_min) / (opt.from_max - opt.from_min)
    percent = Math.min(1, Math.max(percent, 0))
    opt.to_min + (opt.to_max - opt.to_min) * percent

  # ограничение x координаты по ширине рабочей зоны
  _bounded_x: (x) =>
    Math.max(@r, Math.min(@w - @r, x))

  # ограничение y координаты по высоте рабочей зоны
  _bounded_y: (y) =>
    Math.max(@r, Math.min(@h - @r, y))

  # y координата по дате
  _y_by_date: (date) =>
    @_scale date,
      from_min: @min_date
      from_max: @max_date
      to_min: @ry
      to_max: @h - @ry

  render: ->
    @_append_svg()
    @_append_markers()
    @_append_links()
    @_append_nodes()

    # начинаем рисовать
    @d3_force.start().on('tick', @_tick)

  # svg тег
  _append_svg: ->
    @d3_svg = d3.select('body')
      .append('svg')
      .attr
        width: @w
        height: @h
        class: 'images'

  # линии
  _append_links: ->
    @d3_link = @d3_svg.append('svg:g').selectAll('.link')
      .data(@graph.links)
      .enter().append('svg:path')
        .attr
          class: (d) -> 'link ' + d.relation
          'marker-start': (d) -> 'url(#' + d.relation + ')' if START_MARKERS.find(d.relation)
          'marker-end': (d) -> 'url(#' + d.relation + ')' if END_MARKERS.find(d.relation)
          'marker-mid': (d) -> 'url(#' + d.relation + '_label)'

  # картинки
  _append_nodes: ->
    @d3_node = @d3_svg.append('.svg:g').selectAll('.node')
      .data(@graph.nodes)
      .enter().append('svg:g')
        .attr
          class: 'node'
        .call(@d3_force.drag)

    @d3_node.append('svg:image')
      .attr
        class: 'node'
        width: @image_w
        height: @image_h
        'xlink:href': (d) -> d.image_url
      #.on 'click', (d) ->
        #location.href = d.url
      .on 'mouseover', (d) ->
        $(@).siblings('text').show()
      .on 'mouseleave', (d) ->
        $(@).siblings('text').hide()

    # A copy of the text with a thick white stroke for legibility.
    @d3_node.append('svg:text')
      .attr x: 0, y: 95, class: 'title shadow'
      #.text (d) -> "(#{d.id}) #{d.name}"
      .text (d) -> d.name
    @d3_node.append('svg:text')
      .attr x: 0, y: 95, class: 'title'
      #.text (d) -> "(#{d.id}) #{d.name}"
      .text (d) -> d.name

  # маркеры
  _append_markers: ->
    @d3_defs = @d3_svg.append('svg:defs')

    # размер стрелки
    aw = 8
    @d3_defs.append('svg:marker')
      .attr
        id: 'sequel', orient: 'auto'
        refX: aw, refY: aw/2, markerWidth: aw, markerHeight: aw
        stroke: '#123', fill: '#333'
      .append('svg:polyline').attr(points: "0,0 #{aw},#{aw/2} 0,#{aw} #{aw/4},#{aw/2} 0,0")
    @d3_defs.append('svg:marker')
      .attr
        id: 'prequel', orient: 'auto'
        refX: 0, refY: aw/2, markerWidth: aw, markerHeight: aw
        stroke: '#123', fill: '#333'
      .append('svg:polyline').attr(points: "#{aw},#{aw} 0,#{aw/2} #{aw},0 #{aw*3/4},#{aw/2} #{aw},#{aw}")

    #@d3_svg.append('svg:defs').selectAll('marker')
        #.data(['sequel', 'prequel'])
      #.enter().append('svg:marker')
        #.attr
          #refX: 10, refY: 0
          #id: String,
          #markerWidth: 6, markerHeight: 6, orient: 'auto'
          #stroke: '#123', fill: '#123'
          #viewBox: '0 -5 10 10'
      #.append('svg:path')
        #.attr
          #d: (d) ->
            #if START_MARKERS.find(d)
              #"M10,-5L0,0L10,5"
            #else
              #"M0,-5L10,0L0,5"

  # обсчёт координат объектов
  _tick: =>
    @d3_node.attr
      transform: (d) =>
        "translate(#{@_bounded_x(d.x) - @rx}, #{@_bounded_y(d.y) - @ry})"

    @d3_link.attr
      d: @_link_truncated

    @d3_node.each(@_collide(0.5))

  # функцция для получения координат линий
  _link_truncated: (d) =>
    return unless d.source.id < d.target.id
    rx = @rx
    ry = @ry

    x1 = @_bounded_x(d.source.x)
    y1 = @_bounded_y(d.source.y)

    x2 = @_bounded_x(d.target.x)
    y2 = @_bounded_y(d.target.y)

    coords = ShikiMath.square_cutted_line x1, y1, x2, y2, rx, ry

    if !Object.isNaN(coords.x1) && !Object.isNaN(coords.y1) &&
         !Object.isNaN(coords.x2) && !Object.isNaN(coords.y2)
      "M#{coords.x1},#{coords.y1} L#{coords.x2},#{coords.y2}"
    else
      "M#{x1},#{y1} L#{x2},#{y2}"

  # функцция для обсчёта коллизий
  _collide: (alpha) =>
    quadtree = d3.geom.quadtree(@graph.nodes)

    (d) =>
      rb = 2 * @r
      nx1 = d.x - @rx
      nx2 = d.x + @rx
      ny1 = d.y - @ry
      ny2 = d.y + @ry

      quadtree.visit (quad, x1, y1, x2, y2) =>
        if quad.point && quad.point != d
          x = d.x - quad.point.x
          y = d.y - quad.point.y
          l = Math.sqrt(x * x + y * y)

          if l < rb && l != 0
            l = (l - rb) / l * alpha

            x *= l
            y *= l

            d.x = @_bounded_x(d.x - x)
            d.y = @_bounded_y(d.y - y)
            quad.point.x = @_bounded_x(quad.point.x + x)
            quad.point.y = @_bounded_y(quad.point.y + y)

        x1 > nx2 || x2 < nx1 || y1 > ny2 || y2 < ny1

  ## функцция для получения координат линий
  #_link_arc: (d) =>
    #diff_x = @_bounded_x(d.target.x) - @_bounded_x(d.source.x)
    #diff_y = @_bounded_y(d.target.y) - @_bounded_y(d.source.y)

    #path_length = Math.sqrt((diff_x * diff_x) + (diff_y * diff_y))

    #offset_x = (diff_x * (@r + 5) * 2) / path_length
    #offset_y = (diff_y * (@r + 5) * 2) / path_length

    #if d.source.id < d.target.id
      #"M" + (@_bounded_x(d.source.x) + offset_x / 2) + "," +
            #(@_bounded_y(d.source.y) + offset_y / 2) + "L" +
            #(@_bounded_x(d.target.x) - offset_x / 2) + "," +
            #(@_bounded_y(d.target.y) - offset_y / 2)


class @ShikiMath
  @is_above: (x, y, x1, y1, x2, y2) ->
    dx = x2 - x1
    dy = y2 - y1

    dy*x - dx*y + dx*y1 - dy*x1 <= 0

  @sector: (x1, y1, x2, y2, rx, ry) ->
    # left_bottom to right_top
    lb_to_rt = @is_above x2,y2, x1-rx,y1-ry,x1,y1
    # left_top to right_bottom
    lt_to_rb = @is_above x2,y2, x1-rx,y1+ry,x1,y1

    if lb_to_rt && lt_to_rb
      'top'
    else if !lb_to_rt && lt_to_rb
      'right'
    else if !lb_to_rt && !lt_to_rb
      'bottom'
    else
      'left'

  @square_cutted_line: (x1, y1, x2, y2, rx, ry) ->
    dx = x2 - x1
    dy = y2 - y1

    y = (x) -> (dy*x + dx*y1 - dy*x1) / dx
    x = (y) -> (dx*y - dx*y1 + dy*x1) / dy

    target_sector = @sector x1, y1, x2, y2, rx, ry

    if target_sector == 'right'
      f_x1 = x1 + rx
      f_y1 = y(f_x1)

      f_x2 = x2 - rx
      f_y2 = y(f_x2)

    else if target_sector == 'left'
      f_x1 = x1 - rx
      f_y1 = y(f_x1)

      f_x2 = x2 + rx
      f_y2 = y(f_x2)

    if target_sector == 'top'
      f_y1 = y1 + ry
      f_x1 = x(f_y1)

      f_y2 = y2 - ry
      f_x2 = x(f_y2)

    if target_sector == 'bottom'
      f_y1 = y1 - ry
      f_x1 = x(f_y1)

      f_y2 = y2 + ry
      f_x2 = x(f_y2)

    x1: f_x1
    y1: f_y1
    x2: f_x2
    y2: f_y2
    sector: target_sector

  @rspec: ->
    # is_above
    @_assert true, @is_above(-1,2, -1,-1, 1,1)
    @_assert true, @is_above(0,2, -1,-1, 1,1)
    @_assert true, @is_above(0,0, -1,-1, 1,1)
    @_assert true, @is_above(1,2, -1,-1, 1,1)
    @_assert false, @is_above(2,1, -1,-1, 1,1)
    @_assert false, @is_above(-1,-2, -1,-1, 1,1)

    # sector test
    @_assert 'top', @sector(0,0, 0,10, 1,1)
    @_assert 'top', @sector(0,0, 10,10, 1,1)
    @_assert 'right', @sector(0,0, 10,0, 1,1)
    @_assert 'right', @sector(0,0, 10,-10, 1,1)
    @_assert 'bottom', @sector(0,0, 0,-10, 1,1)
    @_assert 'left', @sector(0,0, -10,0, 1,1)

    # square_cutted_line
    @_assert {x1: -9, y1: 0, x2: 9, y2: 0, sector: 'right'}, @square_cutted_line(-10,0, 10,0, 1,1)
    @_assert {x1: 5, y1: 0, x2: -5, y2: 0, sector: 'left'}, @square_cutted_line(10,0, -10,0, 5,1)
    @_assert {x1: 0, y1: 5, x2: 0, y2: -5, sector: 'bottom'}, @square_cutted_line(0,10, 0,-10, 1,5)
    @_assert {x1: 0, y1: -5, x2: 0, y2: 5, sector: 'top'}, @square_cutted_line(0,-10, 0,10, 1,5)

    @_assert {x1: 5, y1: 5, x2: -5, y2: -5, sector: 'left'}, @square_cutted_line(10,10, -10,-10, 5,5)
    @_assert {x1: 0.5, y1: 1, x2: 1.5, y2: 3, sector: 'top'}, @square_cutted_line(0,0, 2,4, 1,1)

  @_assert: (left, right) ->
    unless JSON.stringify(left) == JSON.stringify(right)
      throw "math error: expected #{JSON.stringify left}, got #{JSON.stringify right}"
