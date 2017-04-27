module.exports = {
  test: /\.js(\.erb)?$/,
  exclude: /node_modules/,
  loader: 'babel-loader',
  options: {
    presets: [
      ['env', { modules: false }],
    ],
    // plugins: [
      // require('babel-plugin-es6-promise')
    // ]
  }
}
