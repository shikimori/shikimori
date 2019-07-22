const webpack = require('webpack');
const { environment } = require('@rails/webpacker');

// vue
const { VueLoaderPlugin } = require('vue-loader');
const vueLoader = require('./loaders/vue');

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin());
environment.loaders.prepend('vue', vueLoader);

// fix issue with SASS not working in vue
const getStyleRule = require('@rails/webpacker/package/utils/get_style_rule');

environment.loaders.delete('sass');
environment.loaders.delete('moduleSass');

environment.loaders.insert(
  'sass',
  getStyleRule(/\.sass$/i, false, [
    { loader: 'sass-loader', options: { sourceMap: true, indentedSyntax: true } }
  ]),
  { after: 'css' }
);
environment.loaders.insert(
  'scss',
  getStyleRule(/\.scss$/i, false, [
    {
      loader: 'sass-loader',
      options: { sourceMap: true }
    }
  ]),
  { after: 'sass' }
);
environment.loaders.insert(
  'moduleSass',
  getStyleRule(/\.sass$/i, true, [
    { loader: 'sass-loader', options: { sourceMap: true, indentedSyntax: true } }
  ]),
  { after: 'css' }
);
environment.loaders.insert(
  'moduleScss',
  getStyleRule(/\.scss$/i, true, [
    {
      loader: 'sass-loader',
      options: { sourceMap: true }
    }
  ]),
  { after: 'sass' }
);

environment.loaders.forEach(item => (
  item.value.use.forEach(currentLoader => {
    // fixes issue with webpacker not compatible with css-loader > 3.0
    // https://github.com/rails/webpacker/issues/2162
    if (currentLoader.loader === 'css-loader') {
      // copy localIdentName into modules
      currentLoader.options.modules = {
        localIdentName: '[local]'
        // localIdentName: currentLoader.options.localIdentName
      };
      // delete localIdentName
      delete currentLoader.options.localIdentName;
    }
  })
));

// coffee
// https://github.com/rails/webpacker/issues/2162
const coffee = require('./loaders/coffee');

environment.loaders.prepend('coffee', coffee);

// other
environment.loaders.get('babel').exclude = /node_modules\/(?!delay|p-defer|get-js)/;
environment.loaders.get('file').exclude =
  /\.(js|jsx|coffee|ts|tsx|vue|elm|scss|sass|css|html|json|pug|jade)?(\.erb)?$/;

environment.loaders.append('pug', {
  test: /\.pug$/,
  oneOf: [
    {
      exclude: /\.vue/,
      use: ['pug-loader']
    },
    {
      use: ['pug-plain-loader']
    }
  ]
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

// https://webpack.js.org/migrate/4/#commonschunkplugin
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
