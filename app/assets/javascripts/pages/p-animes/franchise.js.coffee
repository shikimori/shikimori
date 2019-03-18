pageLoad 'animes_franchise', 'mangas_franchise', 'ranobe_franchise', ->
  require.ensure [], (require) ->
    ShikiMath = require 'services/shiki_math'
    FranchiseGraph = require 'services/franchise/graph'
    d3 = require 'd3'

    try
      render ShikiMath, FranchiseGraph, d3
    catch e
      document.write "#{e.name}: #{e.message || JSON.stringify(e)}"
      throw e

render = (ShikiMath, FranchiseGraph, d3) ->
  ShikiMath.rspec()
  $graph = $('.graph')
  d3.json $graph.data('api_url'), (error, data) =>
    @franchise = new FranchiseGraph(data)
    @franchise.render_to $graph[0]

    $('.sticky-tooltip .close').on 'click', ->
      node = $('.node.selected')[0]
      d3.select(node).on('click')(node.__data__)

    #node = $(".node##{$graph.data 'id'}")[0]
    #d3.select(node).on('click')(node.__data__)
