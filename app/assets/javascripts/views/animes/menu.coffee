using 'Animes'
module.exports = class Animes.Menu extends View
  NO_DATA_I18N_KEY = 'frontend.pages.p_animes.no_data'
  TOOLTIP_OPTIONS = require 'helpers/tooltip_options'

  initialize: ->
    @_scores_stats_bar()
    @_statuses_stats_bar()

    @_history() if @_is_history_allowed()

  _scores_stats_bar: ->
    @$("#rates_scores_stats").bar
      filter: (entry, percent) -> percent >= 2
      no_data: ($chart) ->
        $chart.html("<p class='b-nothing_here'>#{I18n.t NO_DATA_I18N_KEY}</p>")

  _statuses_stats_bar: ->
    @$("#rates_statuses_stats").bar
      title: (entry, percent) -> if percent > 15 then entry.value else ''
      no_data: ($chart) ->
        $chart.html("<p class='b-nothing_here'>#{I18n.t NO_DATA_I18N_KEY}</p>")

  _is_history_allowed: ->
    SHIKI_USER.is_signed_in && SHIKI_USER.is_day_registered &&
      SHIKI_USER.is_ignore_copyright

  _history: ->
    $history_block = @$('.history')

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
    $history_block.one 'mouseover', ->
      $.getJSON $(@).attr('data-remote'), (data) ->
        for id of data
          $tooltip = $('.tooltip-details', "#history-entry-#{id}-tooltip")
          continue unless $tooltip.length

          if data[id].length
            $tooltip.html data[id].map((v, k) ->
              "<a class='b-link' href=\"#{v.link}\">#{v.title}</a>"
            ).join('')
          else
            $("#history-entry-#{id}-tooltip").children().remove()

    # anime history tooltips
    $('.person-tooltip', $history_block)
      .tooltip Object.add(TOOLTIP_OPTIONS.ANIME_TOOLTIP,
        position: 'top right'
        offset: [-28, 59]
        relative: true
        place_to_left: true
        predelay: 100
        delay: 100
        effect: 'toggle'
      )
