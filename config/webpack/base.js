const path = require('path');
const { merge, generateWebpackConfig } = require('shakapacker');
const {
  source_path: sourcePath
} = require('shakapacker/package/config');

// const addSassGlobImporter = require('./utils/add_sass_glob_importer');
const excludeVueInCssImporter = require('./utils/exclude_vue_in_css_importer');
const transpileDependencies = require('./utils/transpile_dependencies');
// const addVueSvgLoader = require('./utils/add_vue_svg_loader');
const optimizationConfig = require('./config/optimization');
const pluginsConfig = require('./config/plugins');
const vueConfig = require('./rules/vue');
const pugConfig = require('./rules/pug');

const webpackConfig = generateWebpackConfig();
delete webpackConfig.optimization;

const customConfig = merge(
  pugConfig,
  vueConfig,
  // addVueSvgLoader(
  //   excludeVueInCssImporter(
  //     addSassGlobImporter(
  //       transpileDependencies(webpackConfig)
  //     )
  //   )
  // ),
  excludeVueInCssImporter(webpackConfig),
  optimizationConfig,
  pluginsConfig,
  {
    resolve: {
      extensions: ['.vue'],
      alias: {
        '@': path.resolve(__dirname, '..', '..', sourcePath, 'javascripts')
      }
    }
  }
);

// environment.loaders.get('babel').exclude =
//   /node_modules\/(?!delay|p-defer|get-js|swiper|shiki-utils|shiki-editor|shiki-uploader|shiki-decorators|prosemirror-utils|lowlight|tiny-uri)/; // eslint-disable-line max-len
// environment.loaders.get('file').exclude =
//   /\.(js|vue|scss|sass|css|html|json|pug|jade)?(\.erb)?$/;

// environment.config.resolve.modules = [
//   // fix vue load in ../shiki-editor
//   path.join(__dirname, '../../node_modules')
// ];

// debugger
module.exports = customConfig;
