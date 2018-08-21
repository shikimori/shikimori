import Turbolinks from 'turbolinks'

page_load 'list_imports_show', ->
  # если страница ещё не готова, перегрузимся через 5 секунд
  if $('.b-nothing_here').exists()
    url = location.href
    delay(5000).then ->
      Turbolinks.visit(location.href, true) if url == location.href

  # сворачиваем все списки
  $('.b-options-floated.collapse .action').click()
