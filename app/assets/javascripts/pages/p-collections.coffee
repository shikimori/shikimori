page_load 'collections_new', 'collections_edit', 'collections_create', 'collections_update', ->
  $('.b-shiki_editor').shiki_editor()
  data = $('#collection_form').data('collection')

  require.ensure [], ->
    init_app(
      require('vue/instance').Vue,
      require('vue/components/collections/collection_links.vue'),
      require('vue/store').store,
      data
    )

init_app = (Vue, CollectionLinks, store, data) ->
  store.state.collection = data

  new Vue
    el: '#vue_collection_links'
    store: store
    render: (h) -> h(CollectionLinks)
