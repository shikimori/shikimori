#= require_directory ./p-animes

$(document).on 'page:change', ->
  return if document.body.className.indexOf('p-animes') == -1

  console.log 'process_menu'
  # подсветка нужного пункта в меню
  $(".slider-control a[href='#{location.href}']")
    .closest('.slider-control')
    .addClass('selected')

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
    return  if history_load_triggered
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
