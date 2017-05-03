using 'Collections'
module.exports = class Collections.Edit extends VueView
  initialize: ->
    @$('.b-shiki_editor').shiki_editor()

    el: '#vue_form'
    data:
      links: @$('#vue_form').data('links')
