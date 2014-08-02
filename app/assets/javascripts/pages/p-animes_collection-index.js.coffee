#= require social/addthis_widget

@on 'page:restore', 'animes_collection_index', 'recommendations_index', ->
  # восстановление плюсика у фильтра в актуальное состояние
  $block_filer = $('.block-filter.item-add')
  $block_list = $block_filer.siblings('.block-list')
  if $block_list.find('.filter').length == $block_list.find('.item-minus').length
    $block_filer
      .removeClass('item-add')
      .addClass('item-minus')

@on 'page:load', 'animes_collection_index', 'recommendations_index', ->
  if $('.l-menu .ajax-loading').exists()
    $('.l-menu').one 'ajax:success', init_catalog
  else
    init_catalog()

  new PaginatedCatalog()
  $(document).trigger('page:restore')

init_catalog = ->
  type = if $('.anime-params-controls').exists() then 'anime' else 'manga'
  base_path = "/#{type}s"

  if location.pathname.match(/recommendations/)
    base_path = _(location.pathname.split("/")).first(5).join("/")
    type = "recommendation"

  params = new AnimesParamsParser base_path, location.href, (url) ->
    Turbolinks.visit url, true
    if $('.l-page.menu-expanded').exists()
      $(document).one 'page:change', -> $('.l-page').addClass('menu-expanded')
