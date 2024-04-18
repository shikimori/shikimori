const { VueLoaderPlugin } = require('vue-loader');
const vueSass = require('./vue_sass');

module.exports = {
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: 'vue-loader'
      },
      vueSass
    ]
  },
  plugins: [new VueLoaderPlugin()],
  resolve: {
    extensions: ['.vue']
  }
};
