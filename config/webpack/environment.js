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

environment.plugins.set(
  'ContextReplacement',
  new webpack.ContextReplacementPlugin(/moment[\/\\]locale$/, /ru/)
)

module.exports = environment
