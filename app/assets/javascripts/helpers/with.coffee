# поиск селектора одновременно с добавлением root, если root удовлетворяет селектору
module.exports = window.$with = (selector, $root) ->
  if $root.is(selector)
    $root.find(selector).add($root)
  else
    $root.find(selector)
