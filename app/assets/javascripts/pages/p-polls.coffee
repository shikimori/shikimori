page_load '.polls', ->
  require.ensure [], ->
    init_app(
      require('vue/instance').Vue
      require('vue/components/poll.vue')
      require('vue/stores').collection
    )

init_app = (Vue, Poll, store) ->
  # resource_type = $('#vue_synonyms').data('resource_type')
  # entry_type = $('#vue_synonyms').data('entry_type')
  # entry_id = $('#vue_synonyms').data('entry_id')
  poll_variants = $('#poll_form').data('poll').poll_variants

  store.state.collection = poll_variants.map (poll_variant, index) ->
    key: index
    text: poll_variant.text

  new Vue
    el: '#vue_poll_variants'
    store: store
    render: (h) -> h(Poll)
