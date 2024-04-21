const getStyleRule = require('shakapacker/package/utils/get_style_rule');
const { canProcess } = require('shakapacker/package/utils/helpers');
const { additional_paths: includePaths } = require('shakapacker/package/config');
const globImporter = require('node-sass-glob-importer');
const sass = require('sass');

module.exports = function fixSassRules(webpackConfig) {
  const ruleForScssFiles = canProcess('sass-loader', resolvedPath =>
    getStyleRule(/\.scss(\.erb)?$/i, [
      {
        loader: resolvedPath,
        options: {
          sassOptions: {
            includePaths,
            importer: globImporter()
          },
          implementation: sass
        }
      }
    ])
  );

  const ruleForSassFiles = canProcess('sass-loader', resolvedPath =>
    getStyleRule(/\.sass(\.erb)?$/i, [
      {
        loader: resolvedPath,
        options: {
          sassOptions: {
            includePaths,
            indentedSyntax: true,
            importer: globImporter()
          },
          implementation: sass
        }
      }
    ])
  );

  const indexOfExistingSassRule = webpackConfig.module.rules.findIndex(rule => (
    rule.test.toString() === /\.(scss|sass)(\.erb)?$/i.toString()
  ));

  webpackConfig.module.rules.splice(
    indexOfExistingSassRule,
    1,
    ruleForScssFiles,
    ruleForSassFiles
  );

  return webpackConfig;
};
