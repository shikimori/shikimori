process.env.NODE_ENV = process.env.NODE_ENV || 'development';

const { merge } = require('shakapacker');
const webpackConfig = require('./base');
const WebpackBar = require('webpackbar');

const customConfig = merge(webpackConfig, {
  devServer: {
    devMiddleware: {
      stats: {
        colors: true
      }
    }
  },
  // resolve: {
  //   symlinks: true
  // },
  plugins: [
    new WebpackBar()
  ]
});
module.exports = customConfig;

