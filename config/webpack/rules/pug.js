module.exports = {
  module: {
    rules: [
      {
        test: /\.pug$/,
        // use: ['pug-loader']
        oneOf: [
          {
            exclude: /\.vue$/,
            use: ['pug-loader']
          },
          {
            include: /\.vue$/,
            use: ['pug-plain-loader']
          }
        ]
      }
    ]
  }
};
