page_load 'collections_new', 'collections_edit', 'collections_create', 'collections_update', ->
  require.ensure [], ->
    init_app(
      require('vue/instance').Vue,
      require('vue/components/collections/collection_links.vue'),
      require('vue/store')
    )

init_app = (Vue, CollectionLinks, store) ->
  $root = $('#collection_form')
  collection_links = $root.data('collection_links')

  $root.data('collection_links').forEach (value) ->
    store.dispatch 'add_collection_link', value

  $('.b-shiki_editor', $root).shiki_editor()

  new Vue
    el: '#vue_collection_links'
    store: store
    template: '<CollectionLinks/>',
    components: { CollectionLinks }
