const { merge } = require('shakapacker');

module.exports = function addVueSvgLoader(webpackConfig) {
  webpackConfig.module.rules.forEach(rule => {
    if (rule.test instanceof Array) {
      rule.test = rule.test.filter(test => test.toString() !== '/\\.svg$/');
    }
  });

  // exclude svg from default file loader
  const fileLoader = webpackConfig.module.rules.find(rule => (
    rule.type === 'asset/resource'
  ));
  fileLoader.test = new RegExp(fileLoader.test.source.replace('|svg', ''));

  return merge(
    webpackConfig,
    {
      module: {
        rules: [
          {
            test: /\.svg$/,
            resourceQuery: /inline/,
            use: [
              'vue-loader',
              'vue-svg-loader'
            ]
          },
          {
            test: /\.svg$/,
            resourceQuery: { not: [/inline/] },
            // copied content of default rule for static assets
            // https://github.com/shakacode/shakapacker/blob/master/package/rules/file.js
            generator: fileLoader.generator,
            type: fileLoader.type
          }
        ]
      }
    }
  );
};
