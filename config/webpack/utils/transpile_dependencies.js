const { config } = require('shakapacker');

module.exports = function transpileDependencies(webpackConfig) {
  const babelRule = webpackConfig.module.rules.find(rule =>
    rule.use && rule.use[0] && rule.use[0].loader &&
      // exclude rule became more complex in webpacker/shakapacker 6.6.0
      rule.use[0].loader.includes('babel-loader')
    // return rule.exclude &&
    //   rule.exclude.toString() === '/node_modules/' &&
    //   rule.use[0].loader.includes('babel-loader');
  );
  babelRule.exclude =
    new RegExp(`node_modules/(?!${config.transpile_dependencies.join('|')})`);

  return webpackConfig;
};
