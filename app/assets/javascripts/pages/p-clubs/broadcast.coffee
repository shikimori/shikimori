@on 'page:load', '.clubs-broadcast', ->
  $('.new_broadcast').on 'ajax:success', (e, comment) ->
    next_url = $('.new_broadcast').data('next_url') + '#comment-' + comment.id
    Turbolinks.visit next_url
