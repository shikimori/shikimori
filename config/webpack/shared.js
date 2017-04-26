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

// console.log(JSON.stringify(packPaths.reduce(
    // (map, entry) => {
      // const localMap = map
      // localMap[basename(entry, extname(entry))] = resolve(entry)
      // return localMap
    // }, {}
  // )))

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
    path: resolve(paths.output, paths.entry)
  },

  module: {
    rules: readdirSync(loadersDir).map(file => (
      require(join(loadersDir, file))
    ))
  },

  plugins: [
    // new webpack.ProvidePlugin({
      // $: 'jquery',
      // jQuery: 'jquery',
      // moment: 'moment',
      // I18n: 'i18n-js'
    // }),
    // Avoid publishing files when compilation failed:
    // new webpack.NoEmitOnErrorsPlugin(),
    new webpack.EnvironmentPlugin(JSON.parse(JSON.stringify(env))),
    new ExtractTextPlugin(env.NODE_ENV === 'production' ? '[name]-[hash].css' : '[name].css'),
    new ManifestPlugin({ fileName: 'manifest.json', publicPath, writeToFileEmit: true })
  ],

  resolve: {
    extensions: paths.extensions,
    modules: [
      resolve(paths.source),
      resolve(paths.node_modules)
    ],
    alias: {
      jquery: 'jquery/src/jquery'
    }
  },

  resolveLoader: {
    modules: [paths.node_modules]
  }
}
