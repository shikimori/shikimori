const globImporter = require('node-sass-glob-importer');

module.exports = function addSassGlobImporter(webpackConfig) {
  webpackConfig.module.rules.forEach(rule => {
    rule.use?.forEach(ruleUse => {
      if (!ruleUse.loader?.includes('sass-loader')) { return; }
      ruleUse.options.sassOptions.importer = globImporter();
    });
  });

  return webpackConfig;
};
