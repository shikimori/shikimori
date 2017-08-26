using 'Polls'
module.exports = class Polls.View extends View
  TEMPLATE = 'polls/poll'

  initialize: (@model) ->
    @_render()
    console.log @model.vote

    if @_can_vote()
      @$vote = @$ '.poll-actions .vote'
      @$abstain = @$ '.poll-actions .abstain'
      @_toggle_actions()

      @$('input[type=radio]')
        .on 'click', (e) =>
          if @variant_id == @_checked_radio()?.value
            @_checked_radio().checked = false
            @_toggle_actions()
            @variant_id = null

        .on 'change', (e) =>
          @_toggle_actions()
          @variant_id = @_checked_radio()?.value

      @$vote.on 'click', =>
        checked_variant_id = parseInt @_checked_radio().value
        @_vote(
          @model.variants.find((v) => v.id == checked_variant_id).vote_for_url
        )

      @$abstain.on 'click', =>
        @_vote @model.vote_abstain_url

  _render: ->
    $old_root = @$root
    @_set_root JST[TEMPLATE](model: @model, can_vote: @_can_vote())
    $old_root.replaceWith @$root

  _vote: (url) ->
    @$root.addClass 'b-ajax'
    axios
      .post(url)
      .then (response) =>
        @$root.removeClass 'b-ajax'


  _can_vote: ->
    SHIKI_USER.is_signed_in &&
      @model.state == 'started' && !@model.voted

  _toggle_actions: ->
    if @_checked_radio()
      @$abstain.addClass 'hidden'
      @$vote.removeClass 'hidden'
    else
      @$abstain.removeClass 'hidden'
      @$vote.addClass 'hidden'

  _checked_radio: ->
    @$('input[type=radio]:checked')[0]
