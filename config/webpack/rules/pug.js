module.exports = {
  module: {
    rules: [
      {
        test: /\.pug$/,
        // use: ['pug-loader']
        oneOf: [
          {
            resourceQuery: /^\?vue/,
            use: ['pug-plain-loader']
          },
          {
            exclude: /\.vue$/,
            use: ['pug-loader']
          }
        ]
      }
    ]
  }
};
