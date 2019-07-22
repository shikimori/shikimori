const webpack = require('webpack');
const { environment } = require('@rails/webpacker');

// vue

const { VueLoaderPlugin } = require('vue-loader');
const vueLoader = require('./loaders/vue');

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin());
environment.loaders.prepend('vue', vueLoader);

environment.loaders.forEach(item => {
  if (!item.value.use) { return; }

  item.value.use.forEach(currentLoader => {
    // fixes webpack compilation
    // https://github.com/rails/webpacker/issues/2162
    if (currentLoader.loader === 'css-loader') {
      // Copy localIdentName into modules
      currentLoader.options.modules = {
        localIdentName: currentLoader.options.localIdentName
      };
      // Delete localIdentName
      delete currentLoader.options.localIdentName;
    }

    // fixes issue with SASS not working in vue
    // https://vue-loader.vuejs.org/guide/pre-processors.html#sass-vs-scss
    if (currentLoader.loader === 'sass-loader') {
      currentLoader.options.indentedSyntax = true;
    }
  });
});

// coffee
// https://github.com/rails/webpacker/issues/2162
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

// or using custom config
environment.splitChunks(config => (
  Object.assign({}, config, {
    optimization: {
      runtimeChunk: false,
      splitChunks: {
        chunks: 'all',
        name: 'vendor'
      }
    }
  })
));

module.exports = environment;
