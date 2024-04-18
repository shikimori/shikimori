const getStyleRule = require('shakapacker/package/utils/get_style_rule');
const { canProcess } = require('shakapacker/package/utils/helpers');
const {
  additional_paths: includePaths
} = require('shakapacker/package/config');

const sassRule = canProcess('sass-loader', resolvedPath =>
  getStyleRule(/\.sass$/i, [
    {
      loader: resolvedPath,
      options: {
        sassOptions: {
          includePaths,
          indentedSyntax: true
        },
        implementation: require('sass')
      }
    }
  ])
);

module.exports = {
  ...sassRule,
  include: /\.vue/
};
