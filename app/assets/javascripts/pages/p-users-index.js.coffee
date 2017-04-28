page_load 'users_index', ->
  # если страница ещё не готова, перегрузимся через 5 секунд
  if $('p.pending').exists()
    url = location.href
    delay(5000).then ->
      Turbolinks.visit(location.href, true) if url == location.href
