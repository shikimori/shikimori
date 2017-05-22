module.exports = {
  test: /\.js(\.erb)?$/,
  exclude: /node_modules\/(?!delay|p-defer)/,
  loader: 'babel-loader'
}
