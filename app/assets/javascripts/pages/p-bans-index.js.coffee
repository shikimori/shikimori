@on 'page:load', 'bans_index', ->
  # сокращение высоты инструкции
  $('.b-brief').check_height(150)
