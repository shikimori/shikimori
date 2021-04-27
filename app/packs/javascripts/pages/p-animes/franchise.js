pageLoad('animes_franchise', 'mangas_franchise', 'ranobe_franchise', async () => {
  const d3 = await import(/* webpackChunkName: "d3" */ 'd3');
  const { ShikiMath } = await import(/* webpackChunkName: "franchise" */ 'services/shiki_math');
  const { FranchiseGraph } =
    await import(/* webpackChunkName: "franchise" */ 'services/franchise/graph');

  try {
    render(ShikiMath, FranchiseGraph, d3);
  } catch (e) {
    document.write(`${e.name}: ${e.message || JSON.stringify(e)}`);
    throw e;
  }
});

function render(ShikiMath, FranchiseGraph, d3) {
  if (process.env.NODE_ENV === 'development') {
    ShikiMath.rspec();
  }

  const $graph = $('.graph').empty();

  d3.json($graph.data('api_url'), (error, data) => {
    const graph = new FranchiseGraph(data);
    graph.render_to($graph[0]);

    $('.sticky-tooltip .close').on('click', () => {
      const node = $('.node.selected')[0];
      d3.select(node).on('click')(node.__data__);
    });

    // node = $(".node##{$graph.data 'id'}")[0]
    // d3.select(node).on('click')(node.__data__)
  });
}
