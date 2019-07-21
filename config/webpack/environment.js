const webpack = require('webpack');
const { environment } = require('@rails/webpacker');

// vue
const { VueLoaderPlugin } = require('vue-loader');
const vue = require('./loaders/vue');

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin());
environment.loaders.prepend('vue', vue);

// fix sass in vue https://github.com/rails/webpacker/issues/2162
var loader = environment.loaders.get('css');
loader.use = [{ 'loader':'vue-style-loader' }, ...loader.use];

// loader = environment.loaders.get('sass');
// loader.use = [{ 'loader':'vue-style-loader' }, ...loader.use];

// loader = environment.loaders.get('moduleCss');
// loader.use = [{ 'loader':'vue-style-loader' }, ...loader.use];

// loader = environment.loaders.get('moduleSass');
// loader.use = [{ 'loader':'vue-style-loader' }, ...loader.use];

// loader = environment.loaders.get('nodeModules');
// loader.use = [{ 'loader':'vue-style-loader' }, ...loader.use];

const cssLoader = environment.loaders.get('css')
var loaderLength = cssLoader.use.length
for (var i = 0; i < loaderLength; i++) {
  var loader = cssLoader.use[i]
  if (loader.loader === 'css-loader') {
    // Copy localIdentName into modules
    loader.options.modules = {
      localIdentName: loader.options.localIdentName
    }
    // Delete localIdentName
    delete loader.options.localIdentName
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

// environment.loaders.append('jade', {
//   test: /\.(?:jade|pug)$/,
//   loader: 'pug-loader',
//   exclude: /node_modules/
// });

environment.loaders.append('pug', {
  test: /\.pug$/,
  loader: 'pug-plain-loader',
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
