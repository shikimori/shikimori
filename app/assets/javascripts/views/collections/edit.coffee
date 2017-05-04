CollectionLink = require './collection_link.vue'

using 'Collections'
module.exports = class Collections.Edit extends VueView
  initialize: ->
    @$('.b-shiki_editor').shiki_editor()

    @Vue.component 'collection_link', CollectionLink

    el: '#vue_form'
    data:
      links: @$('#vue_form').data('links')
