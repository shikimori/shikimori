// Change it to false if you prefer Vue styles to be inlined by javascript in runtime
const extractStyles = true

const ExtractTextPlugin = require('extract-text-webpack-plugin')
const { env } = require('../configuration.js')

const cssLoader = [
  { loader: 'css-loader', options: { minimize: env === 'production' } },
  'postcss-loader',
]
const sassLoader = cssLoader.concat(['sass-loader?indentedSyntax'])
const scssLoader = cssLoader.concat(['sass-loader'])

function vueLoader(loader) {
  if (extractStyles) {
    return ExtractTextPlugin.extract({
      fallback: 'vue-style-loader',
      use: loader
    })
  } else {
    return ['vue-style-loader'].concat(sassLoader)
  }
}

module.exports = {
  test: /.vue$/,
  loader: 'vue-loader',
  options: {
    loaders: {
      js: 'babel-loader',
      file: 'file-loader',
      css: vueLoader(cssLoader),
      scss: vueLoader(scssLoader),
      sass: vueLoader(sassLoader)
    }
  }
}
