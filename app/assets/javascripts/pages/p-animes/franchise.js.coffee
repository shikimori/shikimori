ShikiMath = require 'services/shiki_math'

page_load 'animes_franchise', 'mangas_franchise', =>
  try
    ShikiMath.rspec()

    $graph = $('.graph')
    d3.json $graph.data('api-url'), (error, data) =>
      @franchise = new Franchise.Graph(data)
      @franchise.render_to $graph[0]

      $('.sticky-tooltip .close').on 'click', ->
        node = $('.node.selected')[0]
        d3.select(node).on('click')(node.__data__)

      #node = $(".node##{$graph.data 'id'}")[0]
      #d3.select(node).on('click')(node.__data__)

  catch e
    document.write "#{e.name}: #{e.message || JSON.stringify(e)}"
