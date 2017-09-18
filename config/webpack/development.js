const environment = require('./environment')
const FriendlyErrorsWebpackPlugin = require('friendly-errors-webpack-plugin')
const HardSourceWebpackPlugin = require('hard-source-webpack-plugin')

const config = environment.toWebpackConfig()
config.plugins.push(new FriendlyErrorsWebpackPlugin())
config.plugins.push(new HardSourceWebpackPlugin())

module.exports = config
