const webpack = require('webpack')
const environment = require('./environment')

// https://webpack.js.org/plugins/commons-chunk-plugin/
environment.plugins.get('ExtractText').options.allChunks = true
environment.plugins.add({
  key: 'CommonsChunk',
  value: new webpack.optimize.CommonsChunkPlugin({
    name: 'vendor',
    minChunks: function (module) {
      // this assumes your vendor imports exist in the node_modules directory
      return module.context && module.context.indexOf('node_modules') !== -1;
    }
  })
})

// environment.plugins.delete('UglifyJs')
// environment.plugins.delete('Compression')

module.exports = environment.toWebpackConfig()
