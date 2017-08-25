using 'Polls'
module.exports = class Polls.View extends View
  TEMPLATE = 'polls/poll'

  initialize: (@model) ->
    @_render()

    if @_can_vote()
      @$vote = @$ '.poll-actions .vote'
      @$abstain = @$ '.poll-actions .abstain'
      @_toggle_actions()

      @$('input[type=radio]').on 'click', (e) =>
        if @variant_id == @_checked_radio()?.value
          @_checked_radio().checked = false
          @_toggle_actions()
          @variant_id = null

      @$('input[type=radio]').on 'change', (e) =>
        @_toggle_actions()
        @variant_id = @_checked_radio()?.value

  _render: ->
    $old_root = @$root
    @_set_root JST[TEMPLATE](model: @model, can_vote: @_can_vote())
    $old_root.replaceWith @$root

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
