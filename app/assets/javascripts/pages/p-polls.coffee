pageLoad '.polls', ->
  $('.b-shiki_editor').shikiEditor()

  if $('#vue_poll_variants').exists()
    require.ensure [], ->
      init_app(
        require('vue/instance').Vue,
        require('vue/components/poll.vue').default,
        require('vue/stores').collection
      )

init_app = (Vue, Poll, store) ->
  # resource_type = $('#vue_synonyms').data('resource_type')
  # entry_type = $('#vue_synonyms').data('entry_type')
  # entry_id = $('#vue_synonyms').data('entry_id')
  poll_variants = $('#poll_form').data('poll').variants

  store.state.collection = poll_variants.map (poll_variant, index) ->
    key: index
    label: poll_variant.label

  new Vue
    el: '#vue_poll_variants'
    store: store
    render: (h) -> h(Poll)
