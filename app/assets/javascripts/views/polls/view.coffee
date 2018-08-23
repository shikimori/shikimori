axios = require('helpers/axios').default

using 'Polls'
module.exports = class Polls.View extends View
  TEMPLATE = 'polls/poll'

  initialize: (@model) ->
    @_render()

    if @_can_vote()
      @$vote = @$ '.poll-actions .vote'
      @$abstain = @$ '.poll-actions .abstain'
      @_toggle_actions()

      @$('.b-radio').on 'click', @_radio_click

      @$vote.on 'click', @_vote_variant
      @$abstain.on 'click', @_abstain

  # handlers
  _radio_click: (e) =>
    $radio = $(e.currentTarget).find('input')
    $radio.prop checked: !$radio.prop('checked')
    @_toggle_actions()
    false

  _vote_variant: =>
    variant_id = parseInt @_checked_radio().value
    variant = @model.variants.find (v) -> v.id == variant_id

    @model.vote = { is_abstained: false, variant_id: variant.id }
    variant.votes_total += 1

    @_vote variant.vote_for_url

  _abstain: =>
    @model.vote = { is_abstained: true, variant_id: null }
    @_vote @model.vote_abstain_url

  # private functions
  _render: ->
    $old_root = @$root
    @_set_root JST[TEMPLATE](
      model: @model,
      can_vote: @_can_vote()
      bar_percent: @_variant_percent,
      bar_class: @_variant_class
    )
    $old_root.replaceWith @$root

  _vote: (url) ->
    @$root.addClass 'b-ajax'
    axios
      .post(url)
      .then (response) =>
        @$root.removeClass 'b-ajax'
        @_render()

  _can_vote: ->
    window.SHIKI_USER.isSignedIn &&
      @model.state == 'started' &&
      !@model.vote.is_abstained && !@model.vote.variant_id

  _toggle_actions: ->
    if @_checked_radio()
      @$abstain.addClass 'hidden'
      @$vote.removeClass 'hidden'
    else
      @$abstain.removeClass 'hidden'
      @$vote.addClass 'hidden'

  _checked_radio: ->
    @$('input[type=radio]:checked')[0]

  _variant_percent: (variant) =>
    total_votes = @model.variants.sum('votes_total')

    if total_votes == 0
      0
    else
      (100.0 * variant.votes_total / total_votes).round(2)

  _variant_class: (variant) =>
    votes_percent = @_variant_percent(variant)

    if votes_percent <= 80 && votes_percent > 60
      's1'
    else if votes_percent <= 60 && votes_percent > 30
      's2'
    else if votes_percent <= 30
      's1'
    else
      's0'
