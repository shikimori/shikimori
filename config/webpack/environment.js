// https://chrisbateman.github.io/webpack-visualizer/
const webpack = require('webpack')
const { environment } = require('@rails/webpacker')

environment.loaders.get('babel').exclude =
  /node_modules\/(?!delay|p-defer|get-js)/

environment.loaders.get('vue').options.extractCSS = false

environment.loaders.set('jade', {
  test: /\.(?:jade|pug)$/,
  loader: 'pug-loader',
  exclude: /node_modules/
})

environment.plugins.get('ExtractText').options.allChunks = true

environment.plugins.set(
  'Provide',
  new webpack.ProvidePlugin({
    moment: 'moment',
    I18n: 'i18n-js',
    URI: 'urijs',
    Turbolinks: 'turbolinks',
    delay: 'delay',
    throttle: 'throttle-debounce/throttle',
    debounce: 'throttle-debounce/debounce',
  })
)

// https://webpack.js.org/plugins/commons-chunk-plugin/
environment.plugins.set(
  'CommonsChunk',
  new webpack.optimize.CommonsChunkPlugin({
    name: 'vendor',
    minChunks: function (module) {
      // this assumes your vendor imports exist in the node_modules directory
      return module.context && module.context.indexOf('node_modules') !== -1;
    }
  })
)

environment.plugins.set(
  'ContextReplacement',
  new webpack.ContextReplacementPlugin(/moment[\/\\]locale$/, /ru/)
)

module.exports = environment
