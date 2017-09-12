const environment = require('./environment')

environment.plugins.delete('UglifyJs')
environment.plugins.delete('Compression')
module.exports = environment.toWebpackConfig()
