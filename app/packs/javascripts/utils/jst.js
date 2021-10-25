const requireTemplates = require.context('@/templates', true);
export default requireTemplates.keys().reduce(
  (memo, module) => {
    memo[module.replace(/^\.\/|\.\w+$/g, '')] = requireTemplates(module);
    return memo;
  },
  {}
);
