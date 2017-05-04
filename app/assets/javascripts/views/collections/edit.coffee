CollectionLinks = require './collection_links.vue'
# CollectionLink = require './collection_link.vue'
# @Vue.component 'collection_links', CollectionLinks

using 'Collections'
module.exports = class Collections.Edit extends VueView
  initialize: ->
    @collection_links = @$root.data('collection_links')

    # console.log @$root.data('collection_links')

    @$('.b-shiki_editor').shiki_editor()

    CollectionLinks.data = =>
      collection_links: @collection_links

    console.log CollectionLinks

    el: '#vue_collection_links'
    template: '<CollectionLinks/>',
    components: { CollectionLinks }

    # events:
      # ready: ->
        # z=arguments
        # debugger

    # data: ->
