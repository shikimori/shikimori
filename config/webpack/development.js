process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')
const FriendlyErrorsWebpackPlugin = require('friendly-errors-webpack-plugin')

environment.plugins.add({
  key: 'FriendlyErrorsWebpackPlugin',
  value: new FriendlyErrorsWebpackPlugin()
})

module.exports = environment.toWebpackConfig()
