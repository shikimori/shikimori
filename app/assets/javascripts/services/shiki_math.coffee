export class ShikiMath
  # detecting whether point is above or below a line
  # x,y - point
  # x1,y1 - point 1 of line
  # x2,y2 - point 2 of line
  @is_above: (x,y, x1,y1, x2,y2) ->
    dx = x2 - x1
    dy = y2 - y1

    dy*x - dx*y + dx*y1 - dy*x1 <= 0

  # detecting in which "sector" point x2,y2 is located accordingly to
  # rectangular node with center in x1,y1 and width=rx*2 and height=ry*2
  @sector: (x1,y1, x2,y2, rx,ry) ->
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

  # math for obtaining coords for link between two rectangular nodes
  # with center in xN,yN and width=rxN*2 and height=ryN*2
  @square_cutted_line: (x1,y1, x2,y2, rx1,ry1, rx2,ry2) ->
    dx = x2 - x1
    dy = y2 - y1

    y = (x) -> (dy*x + dx*y1 - dy*x1) / dx
    x = (y) -> (dx*y - dx*y1 + dy*x1) / dy

    target_sector = @sector x1,y1, x2,y2, rx1,ry1

    if target_sector == 'right'
      f_x1 = x1 + rx1
      f_y1 = y(f_x1)

      f_x2 = x2 - rx2
      f_y2 = y(f_x2)

    else if target_sector == 'left'
      f_x1 = x1 - rx1
      f_y1 = y(f_x1)

      f_x2 = x2 + rx2
      f_y2 = y(f_x2)

    if target_sector == 'top'
      f_y1 = y1 + ry1
      f_x1 = x(f_y1)

      f_y2 = y2 - ry2
      f_x2 = x(f_y2)

    if target_sector == 'bottom'
      f_y1 = y1 - ry1
      f_x1 = x(f_y1)

      f_y2 = y2 + ry2
      f_x2 = x(f_y2)

    x1: f_x1
    y1: f_y1
    x2: f_x2
    y2: f_y2
    sector: target_sector

  # tests for math
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
    @_assert {x1: -9, y1: 0, x2: 9, y2: 0, sector: 'right'}, @square_cutted_line(-10,0, 10,0, 1,1, 1,1)
    @_assert {x1: 5, y1: 0, x2: -5, y2: 0, sector: 'left'}, @square_cutted_line(10,0, -10,0, 5,1, 5,1)
    @_assert {x1: 0, y1: 5, x2: 0, y2: -5, sector: 'bottom'}, @square_cutted_line(0,10, 0,-10, 1,5, 1,5)
    @_assert {x1: 0, y1: -5, x2: 0, y2: 5, sector: 'top'}, @square_cutted_line(0,-10, 0,10, 1,5, 1,5)

    @_assert {x1: 5, y1: 5, x2: -5, y2: -5, sector: 'left'}, @square_cutted_line(10,10, -10,-10, 5,5, 5,5)
    @_assert {x1: 0.5, y1: 1, x2: 1.5, y2: 3, sector: 'top'}, @square_cutted_line(0,0, 2,4, 1,1, 1,1)

  @_assert: (left, right) ->
    unless JSON.stringify(left) == JSON.stringify(right)
      throw "math error: expected #{JSON.stringify left}, got #{JSON.stringify right}"
