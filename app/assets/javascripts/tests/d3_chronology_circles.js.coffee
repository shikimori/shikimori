class @ChronologyCircles
  constructor: (data) ->
    @graph = data
    @_prepare_data()
    @_prepare_d3()

  _is_const_mode: ->
    @size < 20 && @max_weight < 6

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
        to_min: 320
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

  render: ->
    # svg тег
    svg = d3.select('body')
      .append('svg')
      .attr
        class: 'circles'
        width: @w
        height: @h

    # начинаем рисовать
    @d3_force
      .start()
      .on('tick', @_tick)

    # Per-relation markers, as they don't inherit styles.
    svg.append("svg:defs").selectAll("marker")
        #.data(['adaptation','side_story','spin_off','sequel','alternative_version','prequel','other','summary','alternative_setting','character','parent_story','full_story'])
        .data(['prequel','summary','parent_story','full_story'])
      .enter().append("svg:marker")
        .attr("id", String)
        .attr("viewBox", "0 -5 10 10")
        .attr("refX", 15)
        .attr("refY", -1.5)
        .attr("markerWidth", 6)
        .attr("markerHeight", 6)
        .attr("orient", "auto")
      .append("svg:path")
        .attr("d", "M0,-5L10,0L0,5")

    @d3_path = svg.append('svg:g').selectAll('path')
      .data(@d3_force.links()).enter()
      .append('svg:path')
        .attr
          class: (d) -> 'link ' + d.relation
          'marker-end': (d) -> "url(##{d.relation})"

    @d3_circle = svg.append('svg:g').selectAll('circle')
      .data(@d3_force.nodes()).enter()
      .append('svg:circle')
        .attr(r: 8)
        .call(@d3_force.drag)

    @d3_text = svg.append('svg:g').selectAll('g')
      .data(@d3_force.nodes()).enter()
      .append('svg:g')

    # A copy of the text with a thick white stroke for legibility.
    @d3_text.append('svg:text')
      .attr
        x: 12
        y: '.31em'
        class: 'shadow'
      #.text (d) -> d.name
    @d3_text.append('svg:text')
      .attr
        x: 12
        y: '.31em'
      #.text (d) -> d.name

  # обсчёт координат объектов
  _tick: =>
    @d3_path.attr
      #x1: (d) => @_bounded_x(d.source.x)
      #y1: (d) => @_bounded_y(d.source.y)
      #x2: (d) => @_bounded_x(d.target.x)
      #y2: (d) => @_bounded_y(d.target.y)
      d: (d) ->
        #dx = d.target.x - d.source.x
        #dy = d.target.y - d.source.y
        #dr = Math.sqrt(dx * dx + dy * dy)
        #'M' + d.source.x + ',' + d.source.y + 'A' + dr + ',' + dr + ' 0 0,1 ' + d.target.x + ',' + d.target.y

        dx = d.target.x - d.source.x
        dy = d.target.y - d.source.y
        dr = Math.sqrt(dx * dx + dy * dy)
        "M#{d.source.x},#{d.source.y} #{d.target.x},#{d.target.y}"


    @d3_circle.attr 'transform', (d) =>
      "translate(#{d.x},#{d.y})"

    @d3_text.attr 'transform', (d) =>
      "translate(#{d.x},#{d.y})"
