const webpack = require('webpack');
const { environment } = require('@rails/webpacker');

const IS_LOCAL_SHIKI_PACKAGES = false;

// vue
const { VueLoaderPlugin } = require('vue-loader');
const vueLoader = require('./loaders/vue');

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin());
environment.loaders.prepend('vue', vueLoader);

// pug
const pugLoader = require('./loaders/pug');

environment.loaders.append('pug', pugLoader);

environment.loaders.get('babel').exclude =
  /node_modules\/(?!delay|p-defer|get-js|swiper|shiki-utils|shiki-editor|shiki-uploader|shiki-decorators|prosemirror-utils)/;
environment.loaders.get('file').exclude =
  /\.(js|vue|scss|sass|css|html|json|pug|jade)?(\.erb)?$/;

environment.plugins.append(
  'Provide',
  new webpack.ProvidePlugin({
    I18n: 'i18n-js',
    $: 'jquery',
    jQuery: 'jquery',
    'window.jQuery': 'jquery',
    'window.$': 'jquery'
  })
);

environment.plugins.append(
  'ContextReplacement',
  new webpack.ContextReplacementPlugin(/moment[/\\]locale$/, /ru/)
);

const fixSassInVue = require('./utils/fix_sass_in_vue'); // eslint-disable-line
fixSassInVue(environment);

if (process.env.NODE_ENV !== 'test') {
  const fixChunkName = name => name.replace(/\?.*/, '');

  // https://webpack.js.org/migrate/4/#commonschunkplugin
  environment.splitChunks(config => (
    {
      ...config,
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
              priority: -5,
              name(module, chunks, cacheGroupKey) {
                const moduleFileName = module.identifier().split('/').reduceRight(item => item);
                const allChunksNames = chunks.map(item => item.name).filter(v => v).join('~');
                // return `${cacheGroupKey}-${allChunksNames}-${moduleFileName}`;
                // return allChunksNames || `${cacheGroupKey}-${moduleFileName}`;
                // return allChunksNames || moduleFileName;
                return fixChunkName(`${cacheGroupKey}-${allChunksNames || moduleFileName}`);
              }
            },
            app: {
              chunks: 'async',
              priority: -5,
              name(module, chunks, cacheGroupKey) {
                const moduleFileName = module.identifier().split('/').reduceRight(item => item);
                const allChunksNames = chunks.map(item => item.name).filter(v => v).join('~');
                // return `${cacheGroupKey}-${allChunksNames}-${moduleFileName}`;
                // return allChunksNames || `${cacheGroupKey}-${moduleFileName}`;
                // return allChunksNames || moduleFileName;
                return fixChunkName(`${cacheGroupKey}-${allChunksNames || moduleFileName}`);
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
    }
  ));
}

environment.plugins.append(
  'some_definitions',
  new webpack.DefinePlugin({
    IS_LOCAL_SHIKI_PACKAGES,
    IS_FAYE_LOGGING: true // process.env.NODE_ENV === 'production'
  })
);

module.exports = environment;
