// Note: You must restart bin/webpack-watcher for changes to take effect
/* eslint global-require: 0 */
/* eslint import/no-dynamic-require: 0 */

const webpack = require('webpack')
const { basename, join, resolve } = require('path')
const { sync } = require('glob')
const { readdirSync } = require('fs')
const ExtractTextPlugin = require('extract-text-webpack-plugin')
const ManifestPlugin = require('webpack-manifest-plugin')
const extname = require('path-complete-extname')
const { env, paths, publicPath, loadersDir } = require('./configuration.js')

const extensionGlob = `*{${paths.extensions.join(',')}}*`
const packPaths = sync(join(paths.source, paths.entry, extensionGlob))

module.exports = {
  entry: packPaths.reduce(
    (map, entry) => {
      const localMap = map
      localMap[basename(entry, extname(entry))] = resolve(entry)
      return localMap
    }, {}
  ),

  output: {
    filename: '[name].js',
    path: resolve(paths.output, paths.entry),
    publicPath: join('/', paths.entry, '/')
  },

  module: {
    rules: readdirSync(loadersDir).map(file => (
      require(join(loadersDir, file))
    ))
  },

  plugins: [
    new webpack.ProvidePlugin({
      moment: 'moment',
      I18n: 'i18n-js',
      Turbolinks: 'turbolinks',
      delay: 'delay',
      throttle: 'throttle-debounce/throttle',
      debounce: 'throttle-debounce/debounce'
    }),
    // https://webpack.js.org/plugins/commons-chunk-plugin/
    new webpack.optimize.CommonsChunkPlugin({
      name: 'vendor',
      minChunks: function (module) {
        // this assumes your vendor imports exist in the node_modules directory
        return module.context && module.context.indexOf('node_modules') !== -1;
      }
    }),
    // load only russian momentjs locale
    // http://stackoverflow.com/questions/25384360/how-to-prevent-moment-js-from-loading-locales-with-webpack/25426019#25426019
    new webpack.ContextReplacementPlugin(/moment[\/\\]locale$/, /ru/),
    new webpack.EnvironmentPlugin(JSON.parse(JSON.stringify(env))),
    new ExtractTextPlugin(env.NODE_ENV === 'production' ? '[name]-[hash].css' : '[name].css'),
    new ManifestPlugin({ fileName: 'manifest.json', publicPath, writeToFileEmit: true })
  ],

  resolve: {
    extensions: paths.extensions,
    modules: [
      resolve(paths.source),
      resolve(paths.node_modules)
    ]
  },

  resolveLoader: {
    modules: [paths.node_modules]
  }
}
