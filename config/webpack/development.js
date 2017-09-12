const environment = require('./environment')
const FriendlyErrorsWebpackPlugin = require('friendly-errors-webpack-plugin')

const config = environment.toWebpackConfig()
config.plugins.push(new FriendlyErrorsWebpackPlugin())

module.exports = config
