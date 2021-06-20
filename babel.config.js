module.exports = function(api) {
  const validEnv = ['development', 'test', 'production'];
  const currentEnv = api.env();
  const isDevelopmentEnv = api.env('development');
  const isProductionEnv = api.env('production');
  const isTestEnv = api.env('test');

  if (!validEnv.includes(currentEnv)) {
    throw new Error(
      'Please specify a valid `NODE_ENV` or ' +
        '`BABEL_ENV` environment variables. Valid values are "development", ' +
        '"test", and "production". Instead, received: ' +
        JSON.stringify(currentEnv) +
        '.'
    );
  }

  return {
    sourceType: 'unambiguous',
    presets: [
      isTestEnv && [
        '@babel/preset-env',
        {
          targets: {
            node: 'current'
          }
        }
      ],
      (isProductionEnv || isDevelopmentEnv) && [
        '@babel/preset-env',
        {
          forceAllTransforms: true,
          useBuiltIns: 'entry',
          corejs: 3,
          modules: false,
          bugfixes: true,
          // loose: true,
          exclude: ['transform-typeof-symbol']

          // latest webpacker config https://github.com/rails/webpacker/blob/master/package/babel/preset.js
          // useBuiltIns: 'entry',
          // corejs: '3.8',
          // modules: false,
          // bugfixes: true,
          // loose: true,
          // exclude: ['transform-typeof-symbol']

          // config for fast-async
          // forceAllTransforms: true,
          // useBuiltIns: 'usage',
          // corejs: '3',
          // modules: false,
          // exclude: [
          //   'transform-typeof-symbol',
          //   'transform-async-to-generator',
          //   'transform-regenerator'
          // ]
        }
      ]
    ].filter(Boolean),
    plugins: [
      'babel-plugin-macros',
      '@babel/plugin-syntax-dynamic-import',
      isTestEnv && 'babel-plugin-dynamic-import-node',
      '@babel/plugin-transform-destructuring',
      ['@babel/plugin-proposal-decorators', { legacy: true }],
      ['@babel/plugin-proposal-class-properties', { loose: true }],
      ['@babel/plugin-proposal-private-methods', { loose: true }],
      ['@babel/plugin-proposal-object-rest-spread', { useBuiltIns: true }],
      [
        '@babel/plugin-transform-runtime',
        {
          helpers: false,
          regenerator: true,
          // config for fast-async
          // regenerator: false,
          corejs: false
        }
      ],
      ['@babel/plugin-transform-regenerator', { async: false }],
      // config for fast-async
      // ['module:fast-async', { spec: true }],
      '@babel/plugin-proposal-optional-chaining',
      '@babel/plugin-proposal-logical-assignment-operators',
      [
        '@babel/plugin-proposal-pipeline-operator',
        { proposal: 'minimal' }
      ],
      '@babel/plugin-proposal-partial-application'
    ].filter(Boolean)
  };
};
