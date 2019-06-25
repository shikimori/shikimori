import Cookies from 'js-cookie'

pageLoad 'age_restricted', ->
  $('.confirm').click ->
    Cookies.set $('.confirm').data('cookie'), true,
      expires: 9999
      path: '/'

    location.reload()
