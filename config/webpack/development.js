const environment = require('./environment')
const FriendlyErrorsWebpackPlugin = require('friendly-errors-webpack-plugin')

environment.plugins.set('FriendlyErrorsWebpackPlugin', new FriendlyErrorsWebpackPlugin())
environment.addCacheLoader()

const config = environment.toWebpackConfig()

module.exports = config
