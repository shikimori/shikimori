const environment = require('./environment')
const FriendlyErrorsWebpackPlugin = require('friendly-errors-webpack-plugin')

environment.plugins.set('FriendlyErrorsWebpackPlugin', new FriendlyErrorsWebpackPlugin())
environment.addCacheLoader()

module.exports = environment.toWebpackConfig()
