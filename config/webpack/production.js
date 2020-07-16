// run to get bundle analyzer result
// BUNDLE_ANALYZER=true NODE_ENV=production yarn webpack --config config/webpack/production.js
process.env.NODE_ENV = process.env.NODE_ENV || 'production';

const environment = require('./environment');

const config = environment.toWebpackConfig();

if (process.env.BUNDLE_ANALYZER) {
  const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer'); // eslint-disable-line
  config.plugins.push(new BundleAnalyzerPlugin());
}

module.exports = config;
