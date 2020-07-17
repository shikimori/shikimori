const webpack = require('webpack');
const { environment } = require('@rails/webpacker');

// vue
const { VueLoaderPlugin } = require('vue-loader');
const vueLoader = require('./loaders/vue');

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin());
environment.loaders.prepend('vue', vueLoader);

// coffee
// https://github.com/rails/webpacker/issues/2162
const coffeeLoader = require('./loaders/coffee');

environment.loaders.prepend('coffee', coffeeLoader);

// pug
const pugLoader = require('./loaders/pug');

environment.loaders.append('pug', pugLoader);

// other
environment.loaders.get('babel').exclude =
  /shiki-utils|node_modules\/(?!delay|p-defer|get-js|shiki-utils|shiki-editor|shiki-upload)/;
environment.loaders.get('file').exclude =
  /\.(js|jsx|coffee|ts|tsx|vue|elm|scss|sass|css|html|json|pug|jade)?(\.erb)?$/;

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

const fixSassInVue = require('./utils/fix_sass_in_vue'); // eslint-disable-line
fixSassInVue(environment);

if (process.env.NODE_ENV !== 'test') {
  // https://webpack.js.org/migrate/4/#commonschunkplugin
  environment.splitChunks(config => (
    Object.assign({}, config, {
      optimization: {
        splitChunks: {
          cacheGroups: {
            vendors: {
              test: /[\\/]node_modules[\\/]/,
              chunks: 'initial',
              priority: -10,
              name: 'vendors'
            },
            vendors_async: {
              test: /[\\/]node_modules[\\/]/,
              minChunks: 1,
              chunks: 'async',
              priority: -1,
              name(module, chunks, cacheGroupKey) {
                const moduleFileName = module.identifier().split('/').reduceRight(item => item);
                const allChunksNames = chunks.map(item => item.name).join('~');
                // return `${cacheGroupKey}-${allChunksNames}-${moduleFileName}`;
                // return allChunksNames || `${cacheGroupKey}-${moduleFileName}`;
                // return allChunksNames || moduleFileName;
                return `${cacheGroupKey}-${allChunksNames || moduleFileName}`;
              }
            },
            app_sync: {
              chunks: 'async',
              priority: -5,
              name(module, chunks, cacheGroupKey) {
                const moduleFileName = module.identifier().split('/').reduceRight(item => item);
                const allChunksNames = chunks.map(item => item.name).join('~');
                // return `${cacheGroupKey}-${allChunksNames}-${moduleFileName}`;
                // return allChunksNames || `${cacheGroupKey}-${moduleFileName}`;
                // return allChunksNames || moduleFileName;
                return `${cacheGroupKey}-${allChunksNames || moduleFileName}`;
              }
            },
            vendors_styles: {
              name: 'vendors',
              test: /\.s?(?:c|a)ss$/,
              chunks: 'all',
              minChunks: 1,
              reuseExistingChunk: true,
              enforce: true,
              priority: 1
            }
          }
        },
        runtimeChunk: false,
        namedModules: true,
        namedChunks: true
      }
    })
  ));
}

module.exports = environment;
