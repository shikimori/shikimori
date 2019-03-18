pageLoad 'collections_new', 'collections_edit', 'collections_create', 'collections_update', ->
  $('.b-shiki_editor').shikiEditor()

  if $('#vue_collection_links').exists()
    require.ensure [], ->
      init_app(
        require('vue/instance').Vue,
        require('vue/components/collections/collection_links.vue').default,
        require('vue/stores').collection_links,
      )

# sort with preserving initial order
sort_by_groups = (data) ->
  groups = data.links.map((v) -> v.group).unique()
  data.links = [].concat
    .apply([], Object.values(data.links.groupBy((v) -> v.group)))
  data

init_app = (Vue, CollectionLinks, store) ->
  collection = $('#collection_form').data('collection')
  autocomplete_url = $('#collection_form').data('autocomplete_url')
  max_links = $('#collection_form').data('max_links')

  store.state.collection = sort_by_groups collection

  new Vue
    el: '#vue_collection_links'
    store: store
    render: (h) -> h(CollectionLinks, props: {
      max_links: max_links
      autocomplete_url: autocomplete_url
    })
