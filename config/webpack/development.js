process.env.NODE_ENV = process.env.NODE_ENV || 'development';

const environment = require('./environment');
const WebpackBar = require('webpackbar');

environment.plugins.append('progress', new WebpackBar());

module.exports = environment.toWebpackConfig();
