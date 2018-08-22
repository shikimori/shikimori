import Turbolinks from 'turbolinks'

ShikiEditor = require 'views/application/shiki_editor'

page_load '.clubs-broadcast', ->
  new ShikiEditor('.b-shikiEditor')

  $('.new_broadcast').on 'ajax:success', (e, comment) ->
    next_url = $('.new_broadcast').data('next_url') + '#comment-' + comment.id
    Turbolinks.visit next_url
