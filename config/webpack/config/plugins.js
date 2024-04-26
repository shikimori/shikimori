const {
  ContextReplacementPlugin,
  ProvidePlugin,
  DefinePlugin
} = require('webpack');

module.exports = {
  plugins: [
    new ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      'window.jQuery': 'jquery',
      'window.$': 'jquery'
    }),
    // new ContextReplacementPlugin(/moment[/\\]locale$/, /ru|en|da|es/),
    new DefinePlugin({
      IS_LOCAL_SHIKI_PACKAGES: false,
      IS_FAYE_LOGGING: process.env.NODE_ENV === 'production',
      // IS_FAYE_LOGGING: true, // process.env.NODE_ENV === 'production'
      __VUE_OPTIONS_API__: true,
      __VUE_PROD_DEVTOOLS__: false,
      __VUE_PROD_HYDRATION_MISMATCH_DETAILS__: false
    })
  ]
};
