#= require jquery
#= require core/sugar
#= require d3
#= require tests/d3_chronology_images
#= require tests/d3_chronology_circles

$ ->
  try
    ShikiMath.rspec()

    d3.json "/api/animes/#{$(document.body).data('anime_id')}/chronology.json", (error, data) ->
      new ChronologyImages(data).render()

  catch e
    document.write e.message || e

#intersections:
#rx = image_width / 2
#ry = image_height / 2

#dx = x2 - x1
#dy = y2 - y1

#[ dy*x - dx*y + dx*y1 - dy*x1 = 0 ]
#y = (x) -> (dy*x + dx*y1 - dy*x1) / dx
#x = (y) -> (dx*y - dx*y1 + dy*x1) / dy


#if x1 < x2 && y1 < y2
  #A:
    #x = x1 + rx
    #y = (dy*x + dx*y1 - dy*x1) / dx

  #B:
    #x = x2 - rx
    #y = (dy*x + dx*y1 - dy*x1) / dx
