const environment = require('./environment')
const FriendlyErrorsWebpackPlugin = require('friendly-errors-webpack-plugin')
const HardSourceWebpackPlugin = require('hard-source-webpack-plugin')

environment.plugins.set('HardSourceWebpackPlugin', new HardSourceWebpackPlugin())
environment.plugins.set('FriendlyErrorsWebpackPlugin', new FriendlyErrorsWebpackPlugin())
environment.addCacheLoader()

const config = environment.toWebpackConfig()

module.exports = config
