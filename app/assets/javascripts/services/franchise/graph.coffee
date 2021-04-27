import d3 from 'd3'

import { FranchiseNode } from './node'
import { ShikiMath } from 'services/shiki_math'

START_MARKERS = ['prequel']
END_MARKERS = ['sequel']

export class FranchiseGraph
  constructor: (data) ->
    # image sizes
    @image_w = 48
    @image_h = 75

    @links_data = data.links
    @nodes_data = data.nodes.map (node) =>
      new FranchiseNode(node, @image_w, @image_h, node.id == data.current_id)

    @_prepare_data()
    @_position_nodes()
    @_prepare_force()
    @_check_non_symmetrical_links()

  _prepare_data: ->
    @max_weight = @links_data.map((v) -> v.weight).max() * 1.0
    @size = original_size = @nodes_data.length
    # console.log "nodes: #{@size}, max_weight: #{@max_weight}"

    # screen sizes
    @screen_width =
      if @size < 30
        @_scale @size,
          from_min: 0
          from_max: 30
          to_min: 480
          to_max: 1300
      else
        @_scale @size,
          from_min: 0
          from_max: 100
          to_min: 1600
          to_max: 2461

    @screen_height = @screen_width

    # dates for positioning on Y axis
    min_date = @nodes_data.map((v) -> v.date).min()
    max_date = @nodes_data.map((v) -> v.date).max()

    # do not use min/max dates if they belong to multiple entries
    if @nodes_data.filter((v) -> v.date == min_date).length == 1
      @min_date = min_date * 1.0

    if @nodes_data.filter((v) -> v.date == max_date).length == 1
      @max_date = max_date * 1.0

  # initial nodes positioning
  _position_nodes: ->
    # return unless @min_date && @max_date
    @nodes_data.forEach (d) =>
      d.y = @_y_by_date(d.date)
      d.x = @screen_width / 2.0 - d.rx

      if d.date == @min_date
        d.fixed = true
        # move it proportionally to its relations count
        d.y += @_scale d.weight, from_min: 4, from_max: 20, to_min: 0, to_max: 700

      if d.date == @max_date
        d.fixed = true
        d.y -= 20
        # move it proportionally to its relations count
        d.y -= @_scale d.weight, from_min: 4, from_max: 9, to_min: 0, to_max: 150

  # configure d3 force object
  _prepare_force: ->
    window.d3_force = @d3_force = d3.layout.force()
      .charge (d) ->
        if d.selected
          if d.weight > 100
            -9000
          else
            -5000
        else if d.weight > 100
          -7000
        else if d.weight > 20
          -4000
        else if d.weight > 7
          -3000
        else
          -2000

      .friction 0.9
      .linkDistance (d) =>
        max_width =
          if @max_weight < 3
            @_scale @size, from_min: 2, from_max: 6, to_min: 100, to_max: 300
          else if @max_weight > 100
            @_scale @max_weight, from_min: 30, from_max: 80, to_min: 300, to_max: 1000
          else
            @_scale @max_weight, from_min: 30, from_max: 80, to_min: 300, to_max: 1500

        @_scale 300 * (d.weight / @max_weight),
          from_min: 0
          from_max: 300
          to_min: 150
          to_max: max_width

      .size([@screen_width, @screen_height])
      .nodes(@nodes_data)
      .links(@links_data)

  _check_non_symmetrical_links: ->
    @links_data.forEach (entry_1) =>
      symmetrical_link = @links_data.find (entry_2) ->
        entry_2.source_id == entry_1.target_id && entry_2.target_id == entry_1.source_id

      if !symmetrical_link
        console.warn 'non symmetical link', entry_1

  # scale X which expected to be in [from_min..from_max] to new value in [to_min...to_max]
  _scale: (x, opt) ->
    percent = (x - opt.from_min) / (opt.from_max - opt.from_min)
    percent = Math.min(1, Math.max(percent, 0))
    opt.to_min + (opt.to_max - opt.to_min) * percent

  # bound X coord to be within screen area
  _bound_x: (d, x = d.x) =>
    min = d.rx + 5
    max = @screen_width - d.rx - 5
    Math.max(min, Math.min(max, x))

  # bound Y coord to be within screen area
  _bound_y: (d, y = d.y) =>
    min = d.ry + 5
    max = @screen_width - d.ry - 5
    Math.max(min, Math.min(max, y))

  # determine Y coord by date (oldest to top, newest to bottom)
  _y_by_date: (date) =>
    @_scale date,
      from_min: @min_date
      from_max: @max_date
      to_min: @image_h / 2.0
      to_max: @screen_height - @image_h / 2.0

  render_to: (target) ->
    @_append_svg target
    @_append_markers()
    @_append_links()
    @_append_nodes()

    @d3_force.start().on('tick', @_tick)
    @d3_force.tick() for i in [0..@size*@size]
    @d3_force.stop()

  # handler for node selection
  _node_selected: (d) =>
    if @selected_node
      @selected_node.deselect(@_bound_x, @_bound_y, @_tick)

      if @selected_node == d
        @selected_node = null
        return

    @selected_node = d
    @selected_node.select(@_bound_x, @_bound_y, @_tick)

  # svg tag
  _append_svg: (target) ->
    @d3_svg = d3.select(target)
      .append('svg')
      .attr width: @screen_width, height: @screen_height

  # lines between nodes
  _append_links: ->
    @d3_link = @d3_svg.append('svg:g').selectAll('.link')
      .data(@links_data)
      .enter().append('svg:path')
        .attr
          class: (d) -> "#{d.source_id}-#{d.target_id} link #{d.relation}"
          'marker-start': (d) -> 'url(#' + d.relation + ')' if START_MARKERS.find(d.relation)
          'marker-end': (d) -> 'url(#' + d.relation + ')' if END_MARKERS.find(d.relation)
          'marker-mid': (d) -> 'url(#' + d.relation + '_label)'

  # nodes (images + borders + year)
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
        #.on 'mouseover', (d) ->
          #$(@).children('text').show()
        #.on 'mouseleave', (d) ->
          #$(@).children('text').hide()

    @d3_node.append('svg:path').attr(class: 'border_outer', d: '')
    @d3_image_container = @d3_node.append('svg:g').attr(class: 'image-container')

    @d3_image_container.append('svg:image')
      .attr
        width: (d) -> d.width
        height: (d) -> d.height
        'xlink:href': (d) -> d.image_url

    @d3_image_container.append('svg:path')
      .attr
        class: 'border_inner'
        d: (d) -> "M 0,0 #{d.width},0 #{d.width},#{d.height} 0,#{d.height} 0,0"

    # year
    @d3_image_container.append('svg:text')
      .attr
        x: (d) -> d.yearX()
        y: (d) -> d.yearY()
        class: 'year shadow'
      .text (d) -> d.year
    @d3_image_container.append('svg:text')
      .attr
        x: (d) -> d.yearX()
        y: (d) -> d.yearY()
        class: 'year'
      .text (d) -> d.year

    # kind
    #@d3_image_container.append('svg:text')
      #.attr x: @image_w - 2, y: 0 , class: 'kind shadow'
      #.text (d) -> d.kind
    #@d3_image_container.append('svg:text')
      #.attr x: @image_w - 2, y: 0, class: 'kind'
      #.text (d) -> d.kind

  # markers for links between nodes
  _append_markers: ->
    @d3_defs = @d3_svg.append('svg:defs')

    # arrow size
    aw = 8
    @d3_defs.append('svg:marker')
      .attr
        id: 'sequel', orient: 'auto'
        refX: aw, refY: aw/2, markerWidth: aw, markerHeight: aw
        stroke: '#123', fill: '#333'
      .append('svg:polyline')
      .attr(points: "0,0 #{aw},#{aw/2} 0,#{aw} #{aw/4},#{aw/2} 0,0")
    @d3_defs.append('svg:marker')
      .attr
        id: 'prequel', orient: 'auto'
        refX: 0, refY: aw/2, markerWidth: aw, markerHeight: aw
        stroke: '#123', fill: '#333'
      .append('svg:polyline')
      .attr(points: "#{aw},#{aw} 0,#{aw/2} #{aw},0 #{aw*3/4},#{aw/2} #{aw},#{aw}")

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

  # move nodes and links accordingly to coords calculated by d3.force
  _tick: =>
    @d3_node.attr
      transform: (d) =>
        "translate(#{@_bound_x(d) - d.rx}, #{@_bound_y(d) - d.ry})"

    @d3_link.attr
      d: @_link_truncated

    # collistion detection between nodes
    @d3_node.forEach(@_collide(0.5))

  # math for obtaining coords for links between rectangular nodes
  _link_truncated: (d) =>
    unless location.href.endsWith('?test')
      return unless d.source.id < d.target.id

    rx1 = d.source.rx
    ry1 = d.source.ry

    rx2 = d.target.rx
    ry2 = d.target.ry

    x1 = @_bound_x(d.source)
    y1 = @_bound_y(d.source)

    x2 = @_bound_x(d.target)
    y2 = @_bound_y(d.target)

    coords = ShikiMath.square_cutted_line x1,y1, x2,y2, rx1,ry1, rx2,ry2

    if !Number.isNaN(coords.x1) && !Number.isNaN(coords.y1) &&
         !Number.isNaN(coords.x2) && !Number.isNaN(coords.y2)
      "M#{coords.x1},#{coords.y1} L#{coords.x2},#{coords.y2}"
    else
      "M#{x1},#{y1} L#{x2},#{y2}"

  # math for collision detection. originally it was designed for circle
  # nodes so it is not absolutely accurate for rectangular nodes
  _collide: (alpha) =>
    quadtree = d3.geom.quadtree(@nodes_data)

    (d) =>
      nx1 = d.x - d.width
      nx2 = d.x + d.width

      ny1 = d.y - d.height
      ny2 = d.y + d.height

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

            d.x = @_bound_x(d, d.x - x)
            d.y = @_bound_y(d, d.y - y)
            quad.point.x = @_bound_x(quad.point, quad.point.x + x)
            quad.point.y = @_bound_y(quad.point, quad.point.y + y)

        x1 > nx2 || x2 < nx1 || y1 > ny2 || y2 < ny1
