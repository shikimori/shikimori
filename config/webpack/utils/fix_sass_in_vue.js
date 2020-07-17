const getStyleRule = require('@rails/webpacker/package/utils/get_style_rule'); // eslint-disable-line

function fixLoader(environment, sass, scss) {
  const loader = environment.loaders.get(sass);
  const newLoader = {
    ...JSON.parse(JSON.stringify(loader)),
    test: /\.scss$/i
  };
  if (loader.exclude) { newLoader.exclude = loader.exclude; }
  if (loader.include) { newLoader.include = loader.include; }

  environment.loaders.insert(scss, newLoader, { after: sass });

  loader.test = /\.sass$/i;
  const { options } = loader.use.find(v => v.loader === 'sass-loader');
  if (!options.sassOptions) {
    options.sassOptions = {};
  }
  options.sassOptions.indentedSyntax = true;
}

module.exports = environment => {
  fixLoader(environment, 'sass', 'scss');
  fixLoader(environment, 'moduleSass', 'moduleScss');

  /*
  ** CSS loader fixing issue, See https://github.com/rails/webpacker/issues/2162
  */
  // const cssLoader = environment.loaders.get('css');
  // cssLoader.use = [{ loader: 'vue-style-loader' }, { loader: 'css-loader' }];

  environment.loaders
    .filter(item => item.value.use)
    .forEach(item => (
      item.value.use.forEach(currentLoader => {
        // fixes issue with webpacker not compatible with css-loader > 3.0
        // https://github.com/rails/webpacker/issues/2162
        if (currentLoader.loader === 'css-loader') {
          // copy localIdentName into modules
          currentLoader.options.modules = {
            localIdentName: '[local]'
            // NOTE: have to use '[local]' otherwise vue styles won't be displayed
            // localIdentName: currentLoader.options.localIdentName
          };
          // delete localIdentName
          delete currentLoader.options.localIdentName;
        }
      })
    ));
};
