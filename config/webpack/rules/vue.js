const { VueLoaderPlugin } = require('vue-loader');
const vueSass = require('./vue_sass');

const mockApi = {
  env: function(env) {
    if (env) {
      return process.env.NODE_ENV === env;
    }
    return process.env.NODE_ENV;
  }
};

const babelConfig = require('../../../babel.config')(mockApi);

function convertPluginName(pluginName) {
  // Remove the '@babel/plugin-' prefix and any other similar prefixes if present
  const cleanedName = pluginName.replace(/@babel\/plugin-(proposal-|transform-)?/, '');

  // Split the name at each hyphen to handle kebab-case
  const parts = cleanedName.split('-');

  // Convert parts to camelCase: skip the first part, capitalize the first letter of subsequent parts
  const camelCaseName = parts.map((part, index) => {
    if (index === 0) return part; // Keep the first part lowercase
    return part.charAt(0).toUpperCase() + part.slice(1); // Capitalize the first letter of each subsequent part
  }).join('');

  return camelCaseName;
}

const babelParserPlugins = babelConfig.plugins.filter(Boolean).map(plugin => {
  if (Array.isArray(plugin)) {
    return [convertPluginName(plugin[0]), plugin[1]];
  }
  return convertPluginName(plugin);
});

module.exports = {
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: 'vue-loader',
        options: {
          babelParserPlugins
        }
      },
      vueSass
    ]
  },
  plugins: [new VueLoaderPlugin()],
  resolve: {
    extensions: ['.vue']
  }
};
