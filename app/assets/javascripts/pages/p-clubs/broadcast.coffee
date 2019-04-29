import Turbolinks from 'turbolinks'
import ShikiEditor from 'views/application/shiki_editor'

pageLoad '.clubs-broadcast', ->
  new ShikiEditor('.b-shiki_editor')

  $('.new_broadcast').on 'ajax:success', (e, comment) ->
    next_url = $('.new_broadcast').data('next_url') + '#comment-' + comment.id
    Turbolinks.visit next_url
