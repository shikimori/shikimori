const webpack = require('webpack');
const { environment } = require('@rails/webpacker');

// vue

// VueLoaderPlugin is used in vue-loader > 15.0.0
// const { VueLoaderPlugin } = require('vue-loader');
const vueLoader = require('./loaders/vue');

// environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin());
environment.loaders.prepend('vue', vueLoader);

// https://github.com/rails/webpacker/issues/2162
const cssLoader = environment.loaders.get('css');
for (let i = 0; i < cssLoader.use.length; i++) {
  let currentLoader = cssLoader.use[i];
  if (currentLoader.loader === 'css-loader') {
    // Copy localIdentName into modules
    currentLoader.options.modules = {
      localIdentName: currentLoader.options.localIdentName
    };
    // Delete localIdentName
    delete currentLoader.options.localIdentName;
  }
}

const sassLoader = environment.loaders.get('sass');
for (let i = 0; i < sassLoader.use.length; i++) {
  let currentLoader = sassLoader.use[i];
  if (currentLoader.loader === 'css-loader') {
    // Copy localIdentName into modules
    currentLoader.options.modules = {
      localIdentName: currentLoader.options.localIdentName
    };
    // Delete localIdentName
    delete currentLoader.options.localIdentName;
  }
}

// coffee
const coffee = require('./loaders/coffee');

environment.loaders.prepend('coffee', coffee);

// other
environment.loaders.get('babel').exclude = /node_modules\/(?!delay|p-defer|get-js)/;
environment.loaders.get('file').exclude =
  /\.(js|jsx|coffee|ts|tsx|vue|elm|scss|sass|css|html|json|pug|jade)?(\.erb)?$/;

environment.loaders.append('coffee', coffee);

environment.loaders.append('jade', {
  test: /\.pug$/,
  loader: 'pug-loader',
  exclude: /node_modules|vue/
});

environment.loaders.append('pug', {
  test: /\.pug$/,
  loader: 'pug-plain-loader',
  exclude: /node_modules/,
  include: /vue/
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

// const MomentLocalesPlugin = require('moment-locales-webpack-plugin')
// environment.plugins.prepend('MomentLocalesPlugin', new MomentLocalesPlugin({
//   localesToKeep: ['es-us', 'ru']
// }))


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


// environment.splitChunks();

// // or using custom config
// environment.splitChunks(config => (
//   Object.assign({}, config, { optimization: { splitChunks: false } })
// ));
module.exports = environment;
