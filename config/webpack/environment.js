const webpack = require('webpack');
const { environment } = require('@rails/webpacker');

// vue

const { VueLoaderPlugin } = require('vue-loader');
const vueLoader = require('./loaders/vue');

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin());
environment.loaders.prepend('vue', vueLoader);

environment.loaders.forEach(item => (
  item.value.use.forEach(currentLoader => {
    // fixes issue with webpacker not compatible with css-loader > 3.0
    // https://github.com/rails/webpacker/issues/2162
    if (currentLoader.loader === 'css-loader') {
      // copy localIdentName into modules
      currentLoader.options.modules = {
        localIdentName: currentLoader.options.localIdentName
      };
      // delete localIdentName
      delete currentLoader.options.localIdentName;
    }

    // fix issue with SASS not working in vue
    // https://vue-loader.vuejs.org/guide/pre-processors.html#sass-vs-scss
    // if (currentLoader.loader === 'sass-loader') {
    //   currentLoader.options.indentedSyntax = true;
    // }
  })
));

// fix issue with SASS not working in vue
const moduleRegexp = environment.loaders.get('sass').exclude;
const vueRegexp = /\.vue$/;

const sassLoader = environment.loaders.get('sass');
const moduleSassLoader = environment.loaders.get('moduleSass');

environment.loaders.insert(
  'sassVue',
  {
    ...sassLoader,
    use: JSON.parse(JSON.stringify(sassLoader.use)),
    include: vueRegexp
  },
  { after: 'sass' }
);

environment.loaders.insert(
  'moduleSassVue',
  {
    ...moduleSassLoader,
    use: JSON.parse(JSON.stringify(moduleSassLoader.use)),
    include: [moduleRegexp, vueRegexp]
  },
  { after: 'moduleSass' }
);

environment.loaders.forEach(item => {
  if (item.key !== 'sassVue' && item.key !== 'moduleSassVue') { return; }

  item.value.use.forEach(currentLoader => {
    // https://vue-loader.vuejs.org/guide/pre-processors.html#sass-vs-scss
    if (currentLoader.loader === 'sass-loader') {
      currentLoader.options.indentedSyntax = true;
    }
  });
});

environment.loaders.get('sass').exclude = [moduleRegexp, vueRegexp];
environment.loaders.get('moduleSass').exclude = vueRegexp;

// coffee
// https://github.com/rails/webpacker/issues/2162
const coffee = require('./loaders/coffee');

environment.loaders.prepend('coffee', coffee);

// other
environment.loaders.get('babel').exclude = /node_modules\/(?!delay|p-defer|get-js)/;
environment.loaders.get('file').exclude =
  /\.(js|jsx|coffee|ts|tsx|vue|elm|scss|sass|css|html|json|pug|jade)?(\.erb)?$/;

environment.loaders.append('coffee', coffee);

environment.loaders.append('pug', {
  test: /\.pug$/,
  loader: 'pug-loader',
  exclude: [
    /node_modules/,
    /\/vue\//
  ]
});

environment.loaders.append('pugVue', {
  test: /\.pug$/,
  loader: 'pug-plain-loader',
  exclude: /node_modules/,
  include: /\/vue\//
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
      runtimeChunk: {
        name: 'runtime'
      },
      splitChunks: {
        chunks: 'all',
        name: 'vendor'
      }
    }
  })
));

module.exports = environment;
