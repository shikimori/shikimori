const FILTER_CHUNK_TYPE = {
  ALL: 'all',
  ASYNC: 'async',
  INITIAL: 'initial'
};

function filterChunkByEntryPoint({ chunk, entryName, chunkType } = {}) {
  const validateMap = {
    [FILTER_CHUNK_TYPE.ALL]: () => true,
    [FILTER_CHUNK_TYPE.ASYNC]: () => !chunk.canBeInitial(),
    [FILTER_CHUNK_TYPE.INITIAL]: () => chunk.canBeInitial()
  };

  if (validateMap[chunkType] && validateMap[chunkType]() && chunk.groupsIterable) {
    for (const group of chunk.groupsIterable) { // eslint-disable-line no-restricted-syntax
      let currentGroup = group;

      while (currentGroup) {
        const parentGroup = currentGroup.getParents()[0];

        if (parentGroup) {
          currentGroup = parentGroup;
        } else {
          break;
        }
      }

      // entrypoint
      if (currentGroup.name === entryName) {
        return true;
      }
    }
  }

  return false;
}

module.exports = {
  optimization: {
    // moduleIds: 'named',
    // runtimeChunk: {
    //   name(entrypoint) {
    //     return `runtime~${entrypoint.name}`;
    //   }
    // },
    splitChunks: {
      cacheGroups: {
        application_vendors_initial: {
          priority: -10,
          // name: chunkName,
          test: /node_modules/,
          chunks: chunk => filterChunkByEntryPoint({
            chunk,
            entry: 'application',
            chunkType: FILTER_CHUNK_TYPE.INITIAL
          })
        },
        application_vendors_async: {
          priority: -5,
          // name: chunkName,
          test: /node_modules/,
          chunks: chunk => filterChunkByEntryPoint({
            chunk,
            entry: 'application',
            chunkType: FILTER_CHUNK_TYPE.ASYNC
          })
        },
        admin_vendors_initial: {
          priority: -10,
          // name: chunkName,
          test: /node_modules/,
          chunks: chunk => filterChunkByEntryPoint({
            chunk,
            entry: 'admin',
            chunkType: FILTER_CHUNK_TYPE.INITIAL
          })
        },
        admin_vendors_async: {
          priority: -5,
          // name: chunkName,
          test: /node_modules/,
          chunks: chunk => filterChunkByEntryPoint({
            chunk,
            entry: 'admin',
            chunkType: FILTER_CHUNK_TYPE.ASYNC
          })
        }
      }
    }
  }
};

// module.exports = {
//   optimization: {
//     minimize: process.env.NODE_ENV !== 'development',
//     // runtimeChunk: {
//     //   name(entrypoint) {
//     //     return `runtime~${entrypoint.name}`;
//     //   }
//     // },
//     // moduleIds: 'named',
//     // runtimeChunk: false
//     splitChunks: {
//       cacheGroups: {
//         vendors: {
//           priority: -10,
//           test: /[\\/]node_modules[\\/]/,
//           chunks: 'initial',
//           name: 'vendors',
//           // name: entrypoint => `vendors~${entrypoint.name}`
//           // name(module, chunks, cacheGroupKey) {
//           //   debugger;
//           //   return 'vendors';
//           // }
//         },
//         vendors_styles: {
//           priority: 1,
//           test: /\.s?(?:c|a)ss$/,
//           chunks: 'all',
//           minChunks: 1,
//           reuseExistingChunk: true,
//           enforce: true,
//           name: 'vendors',
//           // name: entrypoint => `vendors~${entrypoint.name}`
//           // name(module, chunks, cacheGroupKey) {
//           //   debugger;
//           //   return 'vendors';
//           // }
//         },
//         vendors_async: {
//           priority: -5,
//           test: /[\\/]node_modules[\\/]/,
//           minChunks: 1,
//           chunks: 'async',
//           name(module, chunks, cacheGroupKey) {
//             const moduleFileName = module.identifier().split('/').reduceRight(item => item);
//             const allChunksNames = chunks.map(item => item.name).filter(v => v).join('~');
//             // return `${cacheGroupKey}-${allChunksNames}-${moduleFileName}`;
//             // return allChunksNames || `${cacheGroupKey}-${moduleFileName}`;
//             // return allChunksNames || moduleFileName;
//             return fixChunkName(`${cacheGroupKey}-${allChunksNames || moduleFileName}`);
//           }
//         },
//         app: {
//           priority: -5,
//           chunks: 'async',
//           name(module, chunks, cacheGroupKey) {
//             const moduleFileName = module.identifier().split('/').reduceRight(item => item);
//             const allChunksNames = chunks.map(item => item.name).filter(v => v).join('~');
//             // return `${cacheGroupKey}-${allChunksNames}-${moduleFileName}`;
//             // return allChunksNames || `${cacheGroupKey}-${moduleFileName}`;
//             // return allChunksNames || moduleFileName;
//             return fixChunkName(`${cacheGroupKey}-${allChunksNames || moduleFileName}`);
//           }
//         }
//       }
//     }
//   }
// };

function chunkName(module, chunks, cacheGroupKey) {
  const moduleFileName = module.identifier().split('/').reduceRight(item => item);
  const allChunksNames = chunks.map(item => item.name).filter(v => v).join('~');
  // return `${cacheGroupKey}-${allChunksNames}-${moduleFileName}`;
  // return allChunksNames || `${cacheGroupKey}-${moduleFileName}`;
  // return allChunksNames || moduleFileName;
  return fixChunkName(`${cacheGroupKey}-${allChunksNames || moduleFileName}`);
}


function fixChunkName(name) {
  return name.replace(/\?.*/, '');
}
