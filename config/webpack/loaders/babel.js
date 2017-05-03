module.exports = {
  test: /\.js(\.erb)?$/,
  exclude: /node_modules\/(?!delay|p-defer)/,
  loader: 'babel-loader',
  options: {
    presets: [
      [
        'env', {
          modules: false,
          // browsers: ['> 1%', 'last 2 versions', 'ie >= 9']
        }
      ],
    ],
    // plugins: [
      // require('babel-plugin-es6-promise')
    // ]
  }
}
