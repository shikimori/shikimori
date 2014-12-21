@on 'page:load', 'profiles_ban', ->
  $('.b-form.ban').on 'ajax:success', ->
    #Turbolinks.visit.bind(Turbolinks, location.href).delay(500)
    location.reload()
