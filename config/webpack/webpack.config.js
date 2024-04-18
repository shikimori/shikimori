const { env, generateWebpackConfig } = require('shakapacker');
const { existsSync } = require('fs');
const { resolve } = require('path');

const webpackConfig = generateWebpackConfig();

const envSpecificConfig = () => {
  const path = resolve(__dirname, `${env.nodeEnv}.js`);
  if (existsSync(path)) {
    console.log(`Loading ENV specific webpack configuration file ${path}`);
    return require(path);
  } else {
    return webpackConfig;
  }
};

const config = envSpecificConfig();
module.exports = config;
