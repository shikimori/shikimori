process.env.NODE_ENV = process.env.NODE_ENV || 'development';

const FriendlyErrorsWebpackPlugin = require('friendly-errors-webpack-plugin');
const environment = require('./environment');

environment.plugins.add({
  key: 'FriendlyErrorsWebpackPlugin',
  value: new FriendlyErrorsWebpackPlugin()
});

module.exports = environment.toWebpackConfig();
