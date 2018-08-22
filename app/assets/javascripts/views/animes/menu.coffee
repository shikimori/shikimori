import delay from 'delay'
import { ANIME_TOOLTIP_OPTIONS, } from 'helpers/tooltip_options'

export default class AnimesMenu extends View
  NO_DATA_I18N_KEY = 'frontend.pages.p_animes.no_data'

  initialize: ->
    @_scores_stats_bar()
    @_statuses_stats_bar()

    # delay is required becase span.person-tooltip
    # is replaced by a.person-tooltip because of linkeable class
    delay(100).then @_history if @_is_history_allowed()

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
    window.SHIKI_USER.isSignedIn && window.SHIKI_USER.isDayRegistered &&
      window.SHIKI_USER.isIgnoreCopyright

  _history: =>
    $history_block = @$('.history')
    source_url = $history_block.attr('data-source_url')
    return unless source_url

    # подгрузка тултипов истории
    $history_block.one 'mouseover', ->
      $.getJSON source_url, (data) ->
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
      .tooltip Object.add(ANIME_TOOLTIP_OPTIONS,
        position: 'top right'
        offset: [-28, 59]
        relative: true
        place_to_left: true
        predelay: 100
        delay: 100
        effect: 'toggle'
      )
