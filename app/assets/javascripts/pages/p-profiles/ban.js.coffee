@on 'page:load', 'profiles_ban', ->
  $('.b-form.new_ban').on 'ajax:success', ->
    $.info('Перезагрузка страницы...')
    location.reload.bind(location).delay(500)

