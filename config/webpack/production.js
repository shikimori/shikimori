process.env.NODE_ENV = process.env.NODE_ENV || 'production';

// const webpack = require('webpack')
const environment = require('./environment');

// environment.plugins.delete('UglifyJs');
// environment.plugins.delete('Compression');

module.exports = environment.toWebpackConfig();
