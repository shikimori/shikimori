module.exports = {
  test: /\.pug$/,
  oneOf: [
    {
      exclude: /\.vue/,
      use: ['pug-loader']
    },
    {
      use: ['pug-plain-loader']
    }
  ]
};
