# require social/addthis_widget

@on 'page:restore', 'animes_collection_index', 'recommendations_index', 'userlist_comparer_show', ->
  # восстановление плюсика у фильтра в актуальное состояние
  $block_filer = $('.block-filter.item-add')
  $block_list = $block_filer.siblings('.block-list')
  if $block_list.find('.filter').length == $block_list.find('.item-minus').length
    $block_filer
      .removeClass('item-add')
      .addClass('item-minus')

@on 'page:load', 'animes_collection_index', 'recommendations_index', 'userlist_comparer_show', ->
  if $('.l-menu .ajax-loading').exists()
    $('.l-menu').one 'postloaded:success', init_catalog
  else
    init_catalog()

  $(document).trigger('page:restore')

init_catalog = ->
  type = if $('.anime-params-controls').exists() then 'anime' else 'manga'
  base_catalog_path = "/#{type}s"

  if location.pathname.match(/\/recommendations\//)
    base_catalog_path = _(location.pathname.split("/")).first(5).join("/")
  else if location.pathname.match(/\/comparer\//)
    base_catalog_path = _(location.pathname.split("/")).first(6).join("/")

  new PaginatedCatalog(base_catalog_path)
