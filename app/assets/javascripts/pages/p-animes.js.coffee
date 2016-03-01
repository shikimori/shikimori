#= require_directory ./p-animes

@on 'page:load', '.animes', '.mangas', ->
  init_animes_menu()
  $('.b-show_more').show_more()

@init_animes_menu = ->
  # графики
  $("#rates_scores_stats").bar
    filter: (entry, percent) -> percent >= 2

  $("#rates_statuses_stats").bar
    title: (entry, percent) -> if percent > 15 then entry.value else ''
    no_data: ($chart) -> $chart.html "<p class='b-nothing_here'>Нет данных</p>"

  @init_history.delay() if USER_SIGNED_IN && DAY_REGISTERED && IGNORE_COPYRIGHT

@init_history = ->
  # генерация истории аниме/манги
  $history_block = $(".l-menu .history")

  # тултипы истории
  #$(".person-tooltip", $history_block).tooltip
    #position: "top right"
    #offset: [
      #-28
      #-28
    #]
    #relative: true
    #place_to_left: true

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
            "<a class='b-link' href=\"#{v.link}\">#{v.title}</a>"
          ).join('')
        else
          $("#history-entry-#{id}-tooltip").children().remove()

  # anime history tooltips
  $('.person-tooltip', $history_block).tooltip $.extend({}, @ANIME_TOOLTIP_OPTIONS,
    position: 'top right'
    offset: [-28, 59]
    relative: true
    place_to_left: true
    predelay: 100
    delay: 100
    effect: 'toggle'
  )
