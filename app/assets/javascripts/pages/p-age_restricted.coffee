pageLoad 'age_restricted', ->
  $('.confirm').click ->
    $.cookie $('.confirm').data('cookie'), true,
      expires: 9999
      path: '/'

    location.reload()
