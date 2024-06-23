module.exports = function excludeVueInCssImporter(webpackConfig) {
  const indexOfExistingSassRule = webpackConfig.module.rules.findIndex(rule => (
    rule.test.toString() === /\.(scss|sass)(\.erb)?$/i.toString()
  ));
  webpackConfig.module.rules[indexOfExistingSassRule].exclude = /\.vue/;

  return webpackConfig;
};
