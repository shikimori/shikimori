// https://chrisbateman.github.io/webpack-visualizer/
const webpack = require('webpack')
const { environment } = require('@rails/webpacker')

const coffee = require('./loaders/coffee')
const vue = require('./loaders/vue')

environment.loaders.get('babel').exclude =
  /node_modules\/(?!delay|p-defer|get-js)/

environment.loaders.get('file').exclude =
  /\.(js|jsx|coffee|ts|tsx|vue|elm|scss|sass|css|html|json|pug)?(\.erb)?$/

environment.loaders.append('vue', vue)
environment.loaders.append('coffee', coffee)

environment.loaders.append('jade', {
  test: /\.(?:jade|pug)$/,
  loader: 'pug-loader',
  exclude: /node_modules/
})
environment.plugins.append(
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

environment.plugins.append(
  'ContextReplacement',
  new webpack.ContextReplacementPlugin(/moment[\/\\]locale$/, /ru/)
)

module.exports = environment
