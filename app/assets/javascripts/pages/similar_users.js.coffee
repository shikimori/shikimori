pending_load = ->
  $pending = $('p.pending')
  if $pending.length
    _.delay ->
        $.getJSON(location.href+'.json').success (data) ->
          content = data.content.trim()
          if _.isEmpty(content)
            pending_load()
          else
            $('.index-list').html content
            process_current_dom()
      , 5000

$ ->
  if $('p.pending').length
    pending_load()
