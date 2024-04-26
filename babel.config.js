module.exports = function config(api) {
  const validEnv = ['development', 'test', 'production'];
  const currentEnv = api.env();
  const isDevelopmentEnv = api.env('development');
  const isProductionEnv = api.env('production');
  const isTestEnv = api.env('test');

  if (!validEnv.includes(currentEnv)) {
    throw new Error(
      `Please specify a valid NODE_ENV or BABEL_ENV environment variable. Valid values are "development", "test", and "production". Instead, received: "${JSON.stringify(
        currentEnv
      )}".`
    );
  }

  return {
    presets: [
      isTestEnv && ['@babel/preset-env', { targets: { node: 'current' } }],
      (isProductionEnv || isDevelopmentEnv) && [
        '@babel/preset-env',
        {
          useBuiltIns: 'entry',
          corejs: '3.8',
          modules: 'auto',
          bugfixes: true,
          exclude: ['transform-typeof-symbol'],
          targets: 'defaults, not ie <= 11, not ie_mob 11, not dead, chrome 49, > 0.05%, not dead'
          // targets: '> 0.05%, not dead'
        }
      ]
    ].filter(Boolean),
    plugins: [
      ['@babel/plugin-transform-runtime', { helpers: false }],
      ['@babel/plugin-proposal-decorators', { legacy: true }],
      ['@babel/plugin-transform-class-properties', { loose: true }],
      ['@babel/plugin-transform-private-methods', { loose: true }],
      ['@babel/plugin-transform-private-property-in-object', { loose: true }],
      ['@babel/plugin-proposal-pipeline-operator', { proposal: 'minimal' }],
      ['@babel/plugin-proposal-partial-application']
    ].filter(Boolean)
  };
};
