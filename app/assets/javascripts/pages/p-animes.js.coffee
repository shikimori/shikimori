#= require_directory ./p-animes

@on 'page:load', '.animes', ->
  # нажатие кнопки Комментировать в меню
  $('.l-menu .comment').on 'click', ->
    $editor = $('.b-topic .editor-container .b-shiki_editor')
    if $editor.exists()
      $editor.focus()
    else
      $(document).one 'page:change', ->
        (-> $('.b-topic .editor-container .b-shiki_editor').focus()).delay()
      Turbolinks.visit $('.head .back').attr('href')

  # генерация истории аниме/манги
  $history_block = $(".menu-right .history")

  # тултипы истории
  $(".person-tooltip", $history_block).tooltip
    position: "top right"
    offset: [
      -28
      -28
    ]
    relative: true
    place_to_left: true

  # подгрузка тултипов истории
  history_load_triggered = false

  $history_block.hover ->
    return if history_load_triggered
    history_load_triggered = true
    $.getJSON $(@).attr("data-remote"), (data) ->
      for id of data
        $tooltip = $(".tooltip-details", "#history-entry-#{id}-tooltip")
        continue unless $tooltip.length

        if data[id].length
          $tooltip.html _.map(data[id], (v, k) ->
            "<a href=\"#{v.link}\" rel=\"nofollow\">#{v.title}</a>"
          ).join('<br />')
        else
          $("#history-entry-#{id}-tooltip").children().remove()

  # anime history tooltips
  $('.person-tooltip').tooltip
    position: 'top right'
    offset: [-28, -22]
    relative: true
    place_to_left: true
