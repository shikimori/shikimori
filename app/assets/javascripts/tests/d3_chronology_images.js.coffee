class @ChronologyImages
  START_MARKERS = ['prequel']
  END_MARKERS = ['sequel']

  constructor: (data) ->
    @graph = data
    @_prepare_data()
    @_prepare_d3()

  _is_const_mode: ->
    #@size < 20 && @max_weight < 6
    false

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

    @image_x_offset = @image_w / 2 + 5
    @images_y_offset = @image_h / 2 + 5

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

  # d3 объекты
  _prepare_d3: ->
    # математический объект для обсчёта координат
    @d3_force = d3.layout.force()
      .charge(-2000)
      .friction 0.7
      .linkDistance (d) =>
        distance = 300
        weight = d.weight / @max_weight
        @_scale distance * weight,
          from_min: 0
          from_max: 300
          to_min: 40
          to_max: 300

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
      to_min: @images_y_offset
      to_max: @h - @images_y_offset

  render: ->
    # svg тег
    svg = d3.select('body')
      .append('svg')
      .attr
        width: @w
        height: @h
        class: 'images'

    # Per-relation markers, as they don't inherit styles.
    # 'adaptation','side_story','spin_off','sequel','alternative_version','prequel','other','summary','alternative_setting','character','parent_story','full_story'
    svg.append("svg:defs").selectAll("marker")
        .data(['sequel', 'prequel'])
      .enter().append('svg:marker')
        .attr
          refX: 10, refY: 0
          id: String,
          markerWidth: 6, markerHeight: 6, orient: 'auto'
          stroke: '#666', fill: '#666'
          viewBox: '0 -5 10 10'
      .append('svg:path')
        .attr
          d: (d) ->
            if START_MARKERS.find(d)
              "M10,-5L0,0L10,5"
            else
              "M0,-5L10,0L0,5"

    # начинаем рисовать
    @d3_force.start().on('tick', @tick)

    # линии
    @d3_link = svg.selectAll('.link')
      .data(@graph.links)
      .enter().append('svg:path')
        .attr
          class: (d) -> 'link ' + d.relation
          'marker-start': (d) -> 'url(#' + d.relation + ')' if START_MARKERS.find(d.relation)
          'marker-end': (d) -> 'url(#' + d.relation + ')' if END_MARKERS.find(d.relation)

    # картинки
    @d3_node = svg.selectAll('.node')
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

    #node.append('title').text (d) -> d.name

  # обсчёт координат объектов
  tick: =>
    @d3_node.attr
      transform: (d) =>
        if @_is_const_mode()
          "translate(#{@_bounded_x(d.x) - @image_w / 2.0}, #{@_y_by_date(d.date) - @image_h / 2.0})"
        else
          "translate(#{@_bounded_x(d.x) - @image_w / 2.0}, #{@_bounded_y(d.y) - @image_h / 2.0})"

    @d3_link.attr
      d: @link_arc
      #x1: (d) => @_bounded_x(d.source.x)
      #y1: (d) => if @_is_const_mode() then @_y_by_date(d.source.date) else @_bounded_y(d.source.y)
      #x2: (d) => @_bounded_x(d.target.x)
      #y2: (d) => if @_is_const_mode() then @_y_by_date(d.target.date) else @_bounded_y(d.target.y)

    @d3_node.each(@_collide(0.5))

  # функция для обсчёта координат линий
  #link_arc: (d) =>
    ##targetX = d.target.x - @r
    ##targetY = d.target.y - @r
    ##dx = targetX - d.source.x
    ##dy = targetY - d.source.y
    ##dr = if (d.straight == 0) then Math.sqrt(dx * dx + dy * dy) else 0

    #if d.source.id < d.target.id
      ##"M" + d.source.x + "," + d.source.y + " L " + targetX + "," + targetY
      #"M#{@_bounded_x d.source.x},#{@_bounded_y d.source.y}" +
        #" L #{@_bounded_x d.target.x},#{@_bounded_y d.target.y}"

  link_arc: (d) =>
    # Total difference in x and y from source to target
    diff_x = @_bounded_x(d.target.x) - @_bounded_x(d.source.x)
    diff_y = @_bounded_y(d.target.y) - @_bounded_y(d.source.y)

    # Length of path from center of source node to center of target node
    path_length = Math.sqrt((diff_x * diff_x) + (diff_y * diff_y))

    # x and y distances from center to outside edge of target node
    offset_x = (diff_x * (@r + 5) * 2) / path_length
    offset_y = (diff_y * (@r + 5) * 2) / path_length

    if d.source.id < d.target.id
      "M" + (@_bounded_x(d.source.x) + offset_x / 2) + "," +
            (@_bounded_y(d.source.y) + offset_y / 2) + "L" +
            (@_bounded_x(d.target.x) - offset_x / 2) + "," +
            (@_bounded_y(d.target.y) - offset_y / 2)

  # функцция для обсчёта коллизий
  _collide: (alpha) =>
    quadtree = d3.geom.quadtree(@graph.nodes)

    (d) =>
      rb = 2 * @r
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
