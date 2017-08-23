// Note: You must restart bin/webpack-dev-server for changes to take effect

const webpack = require('webpack')
const merge = require('webpack-merge')
const sharedConfig = require('./shared.js')
const { join } = require('path')
const FriendlyErrorsWebpackPlugin = require('friendly-errors-webpack-plugin')

module.exports = merge(sharedConfig, {
  devtool: 'sourcemap',

  plugins: [
    new FriendlyErrorsWebpackPlugin()
  ],

  stats: {
    errorDetails: true
  },

  output: {
    pathinfo: true
  }
})
