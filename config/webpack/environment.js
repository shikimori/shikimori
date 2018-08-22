const webpack = require('webpack');
const { environment } = require('@rails/webpacker');

const coffee = require('./loaders/coffee');
const vue = require('./loaders/vue');

environment.loaders.get('babel').exclude =
  /node_modules\/(?!delay|p-defer|get-js)/;

environment.loaders.get('file').exclude =
  /\.(js|jsx|coffee|ts|tsx|vue|elm|scss|sass|css|html|json|pug|jade)?(\.erb)?$/;

environment.loaders.append('vue', vue);
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

// https://webpack.js.org/plugins/commons-chunk-plugin/
environment.plugins.get('ExtractText').options.allChunks = true;
environment.plugins.add({
  key: 'CommonsChunk',
  value: new webpack.optimize.CommonsChunkPlugin({
    name: 'vendor',
    minChunks(module) {
      // this assumes your vendor imports exist in the node_modules directory
      return module.context && module.context.indexOf('node_modules') !== -1;
    }
  })
});

module.exports = environment;
