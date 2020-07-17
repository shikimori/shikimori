const getStyleRule = require('@rails/webpacker/package/utils/get_style_rule'); // eslint-disable-line

module.exports = environment => {
  // fix issue with SASS not working in vue
  environment.loaders.delete('sass');
  environment.loaders.delete('moduleSass');

  environment.loaders.insert(
    'sass',
    getStyleRule(/\.sass$/i, false, [
      { loader: 'sass-loader', options: { sourceMap: true, indentedSyntax: true } }
    ]),
    { after: 'css' }
  );
  environment.loaders.insert(
    'scss',
    getStyleRule(/\.scss$/i, false, [
      {
        loader: 'sass-loader',
        options: { sourceMap: true }
      }
    ]),
    { after: 'sass' }
  );
  environment.loaders.insert(
    'moduleSass',
    getStyleRule(/\.sass$/i, true, [
      { loader: 'sass-loader', options: { sourceMap: true, indentedSyntax: true } }
    ]),
    { after: 'css' }
  );
  environment.loaders.insert(
    'moduleScss',
    getStyleRule(/\.scss$/i, true, [
      {
        loader: 'sass-loader',
        options: { sourceMap: true }
      }
    ]),
    { after: 'sass' }
  );

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
            // localIdentName: currentLoader.options.localIdentName
          };
          // delete localIdentName
          delete currentLoader.options.localIdentName;
        }
      })
    ));
};
