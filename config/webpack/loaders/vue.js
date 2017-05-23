const ExtractTextPlugin = require('extract-text-webpack-plugin')
const { env } = require('../configuration.js')

// Change it to false if you prefer Vue styles to be inlined by javascript in runtime
const extractStyles = false

const cssLoader = [
  { loader: 'css-loader', options: { minimize: env === 'production' } },
  'postcss-loader'
]
const sassLoader = cssLoader.concat(['sass-loader?indentedSyntax'])
const scssLoader = cssLoader.concat(['sass-loader'])

function vueStyleLoader(loader) {
  if (extractStyles) {
    return ExtractTextPlugin.extract({
      fallback: 'vue-style-loader',
      use: loader
    })
  }
  return ['vue-style-loader'].concat(loader)
}

module.exports = {
  test: /.vue$/,
  loader: 'vue-loader',
  options: {
    loaders: {
      js: 'babel-loader',
      file: 'file-loader',
      css: vueStyleLoader(cssLoader),
      scss: vueStyleLoader(scssLoader),
      sass: vueStyleLoader(sassLoader)
    }
  }
}
