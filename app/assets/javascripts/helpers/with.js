export default (selector, $root) => {
  if ($root.is(selector)) {
    return $root.find(selector).add($root);
  }
  return $root.find(selector);
};
