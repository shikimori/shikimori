const environment = require('./environment')
const FriendlyErrorsWebpackPlugin = require('friendly-errors-webpack-plugin')


// const { join } = require('path')
// const { readFileSync } = require('fs')
// const webpacker_config = require('@rails/webpacker/package/config')
// const environment = require('./environment')

environment.plugins.add({
  key: 'FriendlyErrorsWebpackPlugin',
  value: new FriendlyErrorsWebpackPlugin()
})

module.exports = environment.toWebpackConfig()

// const config = environment.toWebpackConfig()

// // cache-loader
// function addCacheLoader(rules) {
//   const cacheLoader = {
//     loader: 'cache-loader',
//     options: {
//       cacheDirectory: join(webpacker_config.cache_path, 'cache-loader')
//     }
//   }

//   for (let rule of rules) {
//     if (rule.use) {
//       rule.use.unshift(cacheLoader)
//     } else if (rule.loader) {
//       let ruleLoader = null
//       if (rule.options) {
//         ruleLoader = { loader: rule.loader, options: rule.options }
//         delete rule.options
//       }
//       rule.use = [cacheLoader, ruleLoader || rule.loader]
//       delete rule.loader
//     }
//   }
//   return rules
// }
// addCacheLoader(config.module.rules)

// // generate certifacte with
// // https://www.shellhacks.com/ru/create-csr-openssl-without-prompt-non-interactive/
// [>
// openssl req \
//     -newkey rsa:2048 \
//     -x509 \
//     -nodes \
//     -keyout config/webpack/ssl/key.pem \
//     -new \
//     -out config/webpack/ssl/server.pem \
//     -subj "/C=RU/O=shikimori/CN=shikimori.local" \
//     -reqexts SAN \
//     -config <(cat /System/Library/OpenSSL/openssl.cnf \
//         <(printf '[SAN]\nsubjectAltName=DNS:localhost, DNS:shikimori.local, DNS:*.shikimori.local')) \
//     -sha256 \
//     -days 3650
// */
// // open certificate in keychain and change trust options to "Always trust"

// // config.devServer.https = {
// //   key: readFileSync(join(__dirname, 'ssl/key.pem')),
// //   cert: readFileSync(join(__dirname, 'ssl/server.pem'))
// // }

// module.exports = config
