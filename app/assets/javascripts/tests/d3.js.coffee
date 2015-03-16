#= require jquery
#= require core/sugar
#= require d3
#= require tests/d3_chronology_images
#= require tests/d3_chronology_circles

$ ->
  d3.json "#{$(document.body).data('anime_id')}/data.json", (error, data) ->
    new ChronologyImages(data).render()
