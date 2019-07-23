import d3 from 'd3'

import axios from 'helpers/axios'

export class FranchiseNode
  SELECT_SCALE = 2
  BORDER_OFFSET = 3

  constructor: (data, @width, @height, @is_current) ->
    Object.assign(@, data)

    @selected = false
    @fixed = false

    if @is_current
      @width = (@width * 1.3).ceil()
      @height = (@height * 1.3).ceil()

    @initial_width = @width
    @initial_height = @height
    @_calc_rs()

  deselect: (bound_x, bound_y, tick) ->
    @selected = false
    @fixed = @pfixed

    #@_d3_kind().style display: 'none'
    @_hide_tooltip()
    @_animate(@initial_width, @initial_height, bound_x, bound_y, tick)

  select: (bound_x, bound_y, tick) ->
    @selected = true
    @pfixed = @fixed # prior fixed
    @fixed = true

    #@_d3_kind().style display: 'inline'
    @_load_tooltip()
    @_animate(
      @initial_width * SELECT_SCALE,
      @initial_height * SELECT_SCALE,
      bound_x,
      bound_y,
      tick
    )

  year_x: (w = @width) ->
    w - 2

  year_y: (h = @height) ->
    h - 2

  _calc_rs: ->
    @rx = @width / 2.0
    @ry = @height / 2.0

  _animate: (new_width, new_height, bound_x, bound_y, tick) ->
    if @selected
      io = d3.interpolate(0, BORDER_OFFSET)
      iw = d3.interpolate(@width, new_width)
      ih = d3.interpolate(@height, new_height)
      @_d3_node().attr class: 'node selected'
    else
      io = d3.interpolate(BORDER_OFFSET, 0)
      iw = d3.interpolate(@width - BORDER_OFFSET*2, new_width)
      ih = d3.interpolate(@height - BORDER_OFFSET*2, new_height)
      @_d3_node().attr class: 'node'

    @_d3_node()
      .transition()
      .duration(500)
      .tween 'animation', =>
        (t) =>
          #t = 1
          o = io(t)
          o2 = o*2
          w = iw(t)
          h = ih(t)

          width_increment = w + o2 - @width
          height_increment = h + o2 - @height

          #@x -= width_increment / 2.0
          #@px -= width_increment / 2.0
          #@y -= height_increment / 2.0
          #@py -= height_increment / 2.0

          @width += width_increment
          @height += height_increment

          @_calc_rs()

          outer_border_path = "M 0,0 #{w + o2},0 #{w + o2},#{h + o2} 0,#{h + o2} 0,0"

          @_d3_node().attr transform: "translate(#{bound_x(@) - @rx}, #{bound_y(@) - @ry})"
          @_d3_outer_border().attr d: outer_border_path
          @_d3_image_container().attr transform: "translate(#{o}, #{o})"
          @_d3_inner_border().attr d: "M 0,0 #{w},0 #{w},#{h} 0,#{h} 0,0"

          @_d3_image().attr width: w, height: h
          @_d3_year().attr x: @year_x(w), y: @year_y(h)
          #@_d3_kind().attr x: @year_x(w)
          tick()

  _hide_tooltip: ->
    $('.sticky-tooltip').hide()

  _load_tooltip: ->
    $('.sticky-tooltip').show().addClass('b-ajax')
    axios.get(@url + '/tooltip').then (response) ->
      $('.sticky-tooltip').removeClass('b-ajax')
      $('.sticky-tooltip > .inner').html(response.data).process()

  _d3_node: ->
    @_node_elem ||= d3.select $(".node##{@id}")[0]

  _d3_image_container: ->
    @_image_container_elem ||= @_d3_node().selectAll('.image-container')

  _d3_image: ->
    @_image_elem ||= @_d3_node().selectAll('image')

  _d3_year: ->
    @_year_elem ||= @_d3_node().selectAll('.year')

  #_d3_kind: ->
    #@_kind_elem ||= @_d3_node().selectAll('.kind')

  _d3_outer_border: ->
    @_outer_border_elem ||= @_d3_node().selectAll('path.border_outer')

  _d3_inner_border: ->
    @_inner_border_elem ||= @_d3_node().selectAll('path.border_inner')
