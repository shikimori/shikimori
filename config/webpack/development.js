// Note: You must restart bin/webpack-dev-server for changes to take effect

const merge = require('webpack-merge')
const sharedConfig = require('./shared.js')
const { settings, output } = require('./configuration.js')

// const { join } = require('path')
const FriendlyErrorsWebpackPlugin = require('friendly-errors-webpack-plugin')
// const notifier = require('node-notifier')
// const ICON = join(__dirname, '../../public/favicons/favicon-144x144.png')

module.exports = merge(sharedConfig, {
  devtool: 'cheap-eval-source-map',
  plugins: [
    new FriendlyErrorsWebpackPlugin()
    // new FriendlyErrorsWebpackPlugin({
      // onErrors: (severity, errors) => {
        // if (severity !== 'error') {
          // return
        // }
        // const error = errors[0];
        // let paths = error.file.split('/')

        // console.log(error)
        // notifier.notify({
          // title: error.name,
          // message: `.../${paths[paths.length-2]}/${paths[paths.length-1]}:${error.originalStack[0].lineNumber}`,
          // subtitle: error.message,
          // icon: ICON,
          // timeout: 10
        // })
      // }
    // })
  ],

  stats: {
    errorDetails: true
  },

  output: {
    pathinfo: true
  },

  devServer: {
    clientLogLevel: 'none',
    https: settings.dev_server.https,
    host: settings.dev_server.host,
    port: settings.dev_server.port,
    contentBase: output.path,
    publicPath: output.publicPath,
    // disableHostCheck: settings.dev_server.disableHostCheck,
    compress: true,
    headers: { 'Access-Control-Allow-Origin': '*' },
    historyApiFallback: true,
    watchOptions: {
      ignored: /node_modules/
    }
  }
})
