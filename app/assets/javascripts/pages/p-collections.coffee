page_load 'collections_new', 'collections_edit', 'collections_create', 'collections_update', ->
  require.ensure [], =>
    Vue = require 'vue/dist/vue.js'
    CollectionLinks = require 'vue/components/collections/collection_links.vue'
    app Vue, CollectionLinks

app = (Vue, CollectionLinks) ->
  $root = $('#collection_form')
  collection_links = $root.data('collection_links')
  $('.b-shiki_editor', $root).shiki_editor()

  CollectionLinks.data = =>
    collection_links: collection_links

  new Vue
    el: '#vue_collection_links'
    template: '<CollectionLinks/>',
    components: { CollectionLinks }

    # events:
      # ready: ->
        # z=arguments
        # debugger

    # data: ->
