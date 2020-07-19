process.env.NODE_ENV = process.env.NODE_ENV || 'development';

const environment = require('./environment');
const WebpackBar = require('webpackbar');

environment.plugins.append('progress', new WebpackBar());

const config = environment.toWebpackConfig();
config.resolve.symlinks = true;
module.exports = config;
