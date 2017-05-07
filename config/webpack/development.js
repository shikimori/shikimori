// Note: You must restart bin/webpack-dev-server for changes to take effect

const webpack = require('webpack')
const merge = require('webpack-merge')
const sharedConfig = require('./shared.js')
const { join } = require('path')
const FriendlyErrorsWebpackPlugin = require('friendly-errors-webpack-plugin')

const notifier = require('node-notifier')
const ICON = join(__dirname, '../../public/favicons/favicon-144x144.png')

module.exports = merge(sharedConfig, {
  devtool: 'sourcemap',

  plugins: [
    new FriendlyErrorsWebpackPlugin({
      onErrors: (severity, errors) => {
        if (severity !== 'error') {
          return
        }
        const error = errors[0];
        let paths = error.file.split('/')

        console.log(error)
        notifier.notify({
          title: error.name,
          message: `.../${paths[paths.length-2]}/${paths[paths.length-1]}:${error.originalStack[0].lineNumber}`,
          subtitle: error.message,
          icon: ICON,
          timeout: 10
        })
      }
    })
  ],

  stats: {
    errorDetails: true
  },

  output: {
    pathinfo: true
  }
})
