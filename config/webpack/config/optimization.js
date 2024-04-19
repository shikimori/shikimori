const FILTER_CHUNK_TYPE = {
  ALL: 'all',
  ASYNC: 'async',
  INITIAL: 'initial'
};

function fixChunkName(name) {
  return name.replace(/\?.*/, '');
}

module.exports = {
  optimization: {
    splitChunks: {
      cacheGroups: {
        vendors: {
          test: /[\\/]node_modules[\\/]/,
          chunks: 'initial',
          priority: -10,
          name: 'vendors'
        },
        vendors_async: {
          test: /[\\/]node_modules[\\/]/,
          minChunks: 1,
          chunks: 'async',
          priority: -5,
          name(module, chunks, cacheGroupKey) {
            const moduleFileName = module.identifier().split('/').reduceRight(item => item);
            const allChunksNames = chunks.map(item => item.name).filter(v => v).join('~');
            // return `${cacheGroupKey}-${allChunksNames}-${moduleFileName}`;
            // return allChunksNames || `${cacheGroupKey}-${moduleFileName}`;
            // return allChunksNames || moduleFileName;
            return fixChunkName(`${cacheGroupKey}-${allChunksNames || moduleFileName}`);
          }
        },
        app: {
          chunks: 'async',
          priority: -5,
          name(module, chunks, cacheGroupKey) {
            const moduleFileName = module.identifier().split('/').reduceRight(item => item);
            const allChunksNames = chunks.map(item => item.name).filter(v => v).join('~');
            // return `${cacheGroupKey}-${allChunksNames}-${moduleFileName}`;
            // return allChunksNames || `${cacheGroupKey}-${moduleFileName}`;
            // return allChunksNames || moduleFileName;
            return fixChunkName(`${cacheGroupKey}-${allChunksNames || moduleFileName}`);
          }
        },
        vendors_styles: {
          name: 'vendors',
          test: /\.s?(?:c|a)ss$/,
          chunks: 'all',
          minChunks: 1,
          reuseExistingChunk: true,
          enforce: true,
          priority: 1
        }
      }
    },
  }
};
