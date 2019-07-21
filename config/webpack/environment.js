const webpack = require('webpack');
const { environment } = require('@rails/webpacker');

// vue
const { VueLoaderPlugin } = require('vue-loader');
const vue = require('./loaders/vue');

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin());
environment.loaders.prepend('vue', vue);

// coffee
const coffee = require('./loaders/coffee');

environment.loaders.prepend('coffee', coffee);

// other
environment.loaders.get('babel').exclude = /node_modules\/(?!delay|p-defer|get-js)/;
environment.loaders.get('file').exclude =
  /\.(js|jsx|coffee|ts|tsx|vue|elm|scss|sass|css|html|json|pug|jade)?(\.erb)?$/;

environment.loaders.append('coffee', coffee);

environment.loaders.append('jade', {
  test: /\.(?:jade|pug)$/,
  loader: 'pug-loader',
  exclude: /node_modules/
});
environment.plugins.append(
  'Provide',
  new webpack.ProvidePlugin({
    I18n: 'i18n-js'
  })
);

environment.plugins.append(
  'ContextReplacement',
  new webpack.ContextReplacementPlugin(/moment[/\\]locale$/, /ru/)
);

// // https://webpack.js.org/migrate/4/#commonschunkplugin
// // https://webpack.js.org/plugins/commons-chunk-plugin/
// environment.plugins.get('ExtractText').options.allChunks = true;
// environment.plugins.add({
//   key: 'CommonsChunk',
//   value: new webpack.optimize.CommonsChunkPlugin({
//     name: 'vendor',
//     minChunks(module) {
//       // this assumes your vendor imports exist in the node_modules directory
//       return module.context && module.context.indexOf('node_modules') !== -1;
//     }
//   })
// });


environment.splitChunks();

// or using custom config
environment.splitChunks(config => (
  Object.assign({}, config, { optimization: { splitChunks: false } })
));

module.exports = environment;
