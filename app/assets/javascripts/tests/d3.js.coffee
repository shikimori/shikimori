#= require jquery
#= require sugar
#= require d3
axios = require('helpers/axios').default

$ ->
  try
    ShikiMath.rspec()

    $graph = $('.graph')
    anime_id = $graph.data('id')

    d3.json "/api/animes/#{anime_id}/franchise", (error, data) ->
      new ChronologyImages(data).render_to $graph[0]

      # trigger select on current element
      node = $(".node##{anime_id}")[0]
      d3.select(node).on('click')(node.__data__)

  catch e
    document.write e.message || e

class @ChronologyNode
  constructor: (data, width, height) ->
    $.extend(@, data)

    @selected = false
    @init_w = @w = width
    @init_h = @h = height
    @_calc_rs()

  deselect: ->
    @selected = false

    @_d3_kind().style display: 'none'
    @_animate(@init_w, @init_h)

  select: ->
    @selected = true

    @_d3_kind().style display: 'inline'
    @_animate(@init_w * 1.5, @init_h * 1.5)
    @_load_tooltip()

  year_x: (w = @w) ->
    w - 2

  year_y: (h = @h) ->
    h - 2

  _calc_rs: ->
    @rx = @w / 2.0
    @ry = @h / 2.0

  _d3_node: ->
    @_node_elem ||= d3.select $(".node##{@id}")[0]

  _d3_image_container: ->
    @_image_container_elem ||= @_d3_node().selectAll('.image-container')

  _d3_image: ->
    @_image_elem ||= @_d3_node().selectAll('image')

  _d3_year: ->
    @_year_elem ||= @_d3_node().selectAll('.year')

  _d3_kind: ->
    @_kind_elem ||= @_d3_node().selectAll('.kind')

  _d3_border: ->
    @_border_elem ||= @_d3_node().selectAll('path.border')

  _animate: (new_width, new_height) ->
    to_initial = new_width == @init_w

    iw = d3.interpolate(@w, new_width)
    ih = d3.interpolate(@h, new_height)
    io = if to_initial then d3.interpolate(4, 0) else d3.interpolate(0, 4)

    @_d3_year()
      .transition()
      .duration(500)
      .ease('linear')
      .attr
        x: @year_x(new_width)
        y: @year_y(new_height)

    @_d3_kind()
      .transition()
      .duration(500)
      .ease('linear')
      .attr
        x: @year_x(new_width)

    @_d3_image()
      .transition()
      .duration(500)
      .ease('linear')
      .attr
        width: new_width
        height: new_height
      .tween 'side-effects', =>
        (t) =>
          o = io(t)
          o2 = o*2
          w = iw(t)
          h = ih(t)

          @w = w + o2
          @h = h + o2
          @_calc_rs()

          border_path = if to_initial
            ''
          else
            "M 0,0 #{w + o2},0 #{w + o2},#{h + o2} 0,#{h + o2} 0,0"

          @_d3_border().attr d: border_path
          @_d3_image_container().attr transform: "translate(#{o}, #{o})"

  _load_tooltip: ->
    $('.sticky-tooltip').addClass('b-ajax')
    axios.get(@url + '/tooltip').then (html) ->
      $('.sticky-tooltip').removeClass('b-ajax').html html

class @ChronologyImages
  START_MARKERS = ['prequel']
  END_MARKERS = ['sequel']

  constructor: (data) ->
    # изображение
    @image_w = 48
    @image_h = 75

    @links_data = data.links
    @nodes_data = data.nodes.map (data) => new ChronologyNode(data, @image_w, @image_h)

    @_prepare_data()
    @_position_nodes()
    @_prepare_d3()

  # базовые константы
  _prepare_data: ->
    @max_weight = @links_data.map((v) -> v.weight).max() * 1.0
    @size = original_size = @nodes_data.length
    console.log "nodes: #{@size}, max_weight: #{@max_weight}"

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
    @min_date = @nodes_data.map((v) -> v.date).min() * 1.0
    @max_date = @nodes_data.map((v) -> v.date).max() * 1.0

  # начальное позиционирование узлов
  _position_nodes: ->
    @nodes_data.forEach (d) =>
      d.y = @_y_by_date(d.date)
      d.x = @w / 2.0 - d.rx

      if d.date == @min_date
        d.fixed = true
        # смещение пропорционально количеству связей
        d.y += @_scale d.weight, from_min: 4, from_max: 20, to_min: 0, to_max: 700

      if d.date == @max_date
        d.fixed = true
        d.y -= 20
        # смещение пропорционально количеству связей
        d.y -= @_scale d.weight, from_min: 4, from_max: 9, to_min: 0, to_max: 150

  # d3 объекты
  _prepare_d3: ->
    # математический объект для обсчёта координат
    @d3_force = d3.layout.force()
      .charge (d) ->
        if d.selected
          -5000
        else if d.weight > 7
          -3000
        else if d.weight > 20
          -4000
        else
          -2000

      .friction 0.7
      .linkDistance (d) =>
        max_width = if @max_weight < 3
          @_scale @size, from_min: 2, from_max: 6, to_min: 100, to_max: 300
        else
          @_scale @max_weight, from_min: 30, from_max: 80, to_min: 300, to_max: 1500

        @_scale 300 * (d.weight / @max_weight),
          from_min: 0
          from_max: 300
          to_min: 150
          to_max: max_width

      .size([@w, @h])
      .nodes(@nodes_data)
      .links(@links_data)

  # масштабрирование x в интервале [min,max] в долях от max_x
  _scale: (x, opt) ->
    percent = (x - opt.from_min) / (opt.from_max - opt.from_min)
    percent = Math.min(1, Math.max(percent, 0))
    opt.to_min + (opt.to_max - opt.to_min) * percent

  # ограничение x координаты по ширине рабочей зоны
  _bounded_x: (d, x = d.x) =>
    min = d.rx + 5
    max = @w - d.rx - 5
    Math.max(min, Math.min(max, x))

  # ограничение y координаты по высоте рабочей зоны
  _bounded_y: (d, y = d.y) =>
    min = d.ry + 5
    max = @w - d.ry - 5
    Math.max(min, Math.min(max, y))

  # y координата по дате
  _y_by_date: (date) =>
    @_scale date,
      from_min: @min_date
      from_max: @max_date
      to_min: @image_h / 2.0
      to_max: @h - @image_h / 2.0

  render_to: (target) ->
    @_append_svg target
    @_append_markers()
    @_append_links()
    @_append_nodes()

    # начинаем рисовать
    @d3_force.start().on('tick', @_tick)

  # выбран какой-то из узлов
  _node_selected: (d) =>
    if @selected_node
      @selected_node.deselect()

      if @selected_node == d
        return @selected_node = null

    @selected_node = d
    @selected_node.select()

    @d3_force.start()

  # svg тег
  _append_svg: (target) ->
    @d3_svg = d3.select(target)
      .append('svg')
      .attr width: @w, height: @h

  # линии
  _append_links: ->
    @d3_link = @d3_svg.append('svg:g').selectAll('.link')
      .data(@links_data)
      .enter().append('svg:path')
        .attr
          class: (d) -> 'link ' + d.relation
          'marker-start': (d) -> 'url(#' + d.relation + ')' if START_MARKERS.find(d.relation)
          'marker-end': (d) -> 'url(#' + d.relation + ')' if END_MARKERS.find(d.relation)
          'marker-mid': (d) -> 'url(#' + d.relation + '_label)'

  # картинки
  _append_nodes: ->
    @d3_node = @d3_svg.append('.svg:g').selectAll('.node')
      .data(@nodes_data)
      .enter().append('svg:g')
        .attr
          class: 'node'
          id: (d) -> d.id
        .call(@d3_force.drag()
          #.on('dragstart', -> $(@).children('text').hide())
          #.on('dragend', -> $(@).children('text').show())
        )
        .on 'click', (d) =>
          return if d3.event?.defaultPrevented
          @_node_selected(d)
          @d3_force.start()
        #.on 'mouseover', (d) ->
          #$(@).children('text').show()
        #.on 'mouseleave', (d) ->
          #$(@).children('text').hide()

    @d3_node.append('svg:path')
      .attr
        class: 'border'
        d: (d) -> "M 0,0 #{d.w},0 #{d.w},#{d.h} 0,#{d.h} 0,0"

    @d3_image_container = @d3_node.append('svg:g')
      .attr class: 'image-container'

    @d3_image_container.append('svg:image')
      .attr
        width: @image_w
        height: @image_h
        'xlink:href': (d) -> d.image_url

    # year
    @d3_image_container.append('svg:text')
      .attr
        x: (d) -> d.year_x()
        y: (d) -> d.year_y()
        class: 'year shadow'
      .text (d) -> d.year
    @d3_image_container.append('svg:text')
      .attr
        x: (d) -> d.year_x()
        y: (d) -> d.year_y()
        class: 'year'
      .text (d) -> d.year

    # kind
    @d3_image_container.append('svg:text')
      .attr x: @image_w - 2, y: 0 , class: 'kind shadow'
      .text (d) -> d.kind
    @d3_image_container.append('svg:text')
      .attr x: @image_w - 2, y: 0, class: 'kind'
      .text (d) -> d.kind

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
        "translate(#{@_bounded_x(d) - d.rx}, #{@_bounded_y(d) - d.ry})"

    @d3_link.attr
      d: @_link_truncated

    @d3_node.forEach(@_collide(0.5))

  # функцция для получения координат линий
  _link_truncated: (d) =>
    return unless d.source.id < d.target.id

    rx1 = d.source.rx
    ry1 = d.source.ry

    rx2 = d.target.rx
    ry2 = d.target.ry

    x1 = @_bounded_x(d.source)
    y1 = @_bounded_y(d.source)

    x2 = @_bounded_x(d.target)
    y2 = @_bounded_y(d.target)

    coords = ShikiMath.square_cutted_line x1,y1, x2,y2, rx1,ry1, rx2,ry2

    if !Number.isNaN(coords.x1) && !Number.isNaN(coords.y1) &&
         !Number.isNaN(coords.x2) && !Number.isNaN(coords.y2)
      "M#{coords.x1},#{coords.y1} L#{coords.x2},#{coords.y2}"
    else
      "M#{x1},#{y1} L#{x2},#{y2}"

  # функцция для обсчёта коллизий
  _collide: (alpha) =>
    quadtree = d3.geom.quadtree(@nodes_data)

    (d) =>
      nx1 = d.x - d.w
      nx2 = d.x + d.w

      ny1 = d.y - d.h
      ny2 = d.y + d.h

      quadtree.visit (quad, x1, y1, x2, y2) =>
        if quad.point && quad.point != d
          rb = Math.max(d.rx + quad.point.rx, d.ry + quad.point.ry) * 1.15

          x = d.x - quad.point.x
          y = d.y - quad.point.y
          l = Math.sqrt(x * x + y * y)

          if l < rb && l != 0
            l = (l - rb) / l * alpha

            x *= l
            y *= l

            d.x = @_bounded_x(d, d.x - x)
            d.y = @_bounded_y(d, d.y - y)
            quad.point.x = @_bounded_x(quad.point, quad.point.x + x)
            quad.point.y = @_bounded_y(quad.point, quad.point.y + y)

        x1 > nx2 || x2 < nx1 || y1 > ny2 || y2 < ny1
