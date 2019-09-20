export default (selector, $root) => {
  const $filteredRoot = $root.filter(selector);

  if ($filteredRoot.length) {
    return $root.find(selector).add($filteredRoot);
  }

  return $root.find(selector);
};
