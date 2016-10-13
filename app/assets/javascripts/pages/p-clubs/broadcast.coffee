@on 'page:load', '.clubs-broadcast', ->
  $('.new_broadcast').on 'ajax:success', ->
    console.log 'success'
