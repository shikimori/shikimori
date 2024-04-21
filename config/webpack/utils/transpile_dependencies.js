const { config } = require('shakapacker');

module.exports = function transpileDependencies(webpackConfig) {
  if (config.transpile_dependencies && config.transpile_dependencies.length) {
    const babelRule = webpackConfig.module.rules.find(rule =>
      rule.use && rule.use[0] && rule.use[0].loader &&
        rule.use[0].loader.includes('babel-loader')
    );
    babelRule.exclude =
      new RegExp(`node_modules/(?!${config.transpile_dependencies.join('|')})`);
  }

  return webpackConfig;
};
