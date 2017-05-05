module.exports = {
  test: /\.js(\.erb)?$/,
  exclude: /node_modules\/(?!delay|p-defer)/,
  loader: 'babel-loader',
  options: {
    presets: [
      [
        'env', {
          modules: false,
          // loose: true,
          // useBuiltIns: true,
          // browsers: ['> 1%', 'last 2 versions', 'ie >= 9'],
          // debug: true
        }
      ]
    ],
    plugins: ['transform-object-rest-spread']
  }
}
