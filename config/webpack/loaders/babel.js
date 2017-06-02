module.exports = {
  test: /\.js(\.erb)?$/,
  exclude: /node_modules\/(?!delay|p-defer|get-js)/,
  loader: 'babel-loader',
}
