const { join } = require('path')
const webpacker_config = require('@rails/webpacker/package/config')
const environment = require('./environment')
const FriendlyErrorsWebpackPlugin = require('friendly-errors-webpack-plugin')

environment.plugins.set('FriendlyErrorsWebpackPlugin', new FriendlyErrorsWebpackPlugin())

const config = environment.toWebpackConfig()

// cache-loader
function addCacheLoader(rules) {
  const cacheLoader = {
    loader: 'cache-loader',
    options: {
      cacheDirectory: join(webpacker_config.cache_path, 'cache-loader')
    }
  }

  for (let rule of rules) {
    if (rule.use) {
      rule.use.unshift(cacheLoader)
    } else if (rule.loader) {
      let ruleLoader = null
      if (rule.options) {
        ruleLoader = { loader: rule.loader, options: rule.options }
        delete rule.options
      }
      rule.use = [cacheLoader, ruleLoader || rule.loader]
      delete rule.loader
    }
  }
  return rules
}
addCacheLoader(config.module.rules)


module.exports = config
