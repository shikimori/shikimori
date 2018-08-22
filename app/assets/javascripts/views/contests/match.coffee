delay = require 'delay'

using 'Contests'
module.exports = class Contests.Match extends View
  VOTE_LEFT = 'left'
  VOTE_RIGHT = 'right'
  VOTE_ABSTAIN = 'abstain'

  initialize: (vote, @round_view) ->
    @model = @$root.data('model')
    @vote = vote || {}

    @$left = @$('.match-member[data-variant="left"]')
    @$right = @$('.match-member[data-variant="right"]')

    @$('.next-match').on 'click', @_next_match
    @$('.prev-match').on 'click', @_prev_match
    @$('.action .to-next-not-voted').on 'click', @_next_not_voted_match
    @$('.match-member img').on 'click', @_vote_click

    @$('.match-member').on 'ajax:success', @_vote_member
    @$('.action .abstain').on 'ajax:success', @_abstain

    if @_is_started()
      @$('.match-member .b-catalog_entry').hover(
        (e) =>
          return if @vote.vote

          @$('.match-member').addClass('unhovered')
          $(e.target)
            .closest('.match-member')
            .removeClass('unhovered')
            .addClass('hovered')

        , =>
          @$('.match-member').removeClass('hovered unhovered')
      )

      @_set_vote @vote.vote

    @initialized = true

  # handlers
  _next_match: =>
    @round_view.switch_match @round_view.next_match_id(@model.id)

  _prev_match: =>
    @round_view.switch_match @round_view.prev_match_id(@model.id)

  _next_not_voted_match: =>
    @round_view.switch_match @_next_match_id()

  _abstain: (e) =>
    # $(e.target).yellowFade()
    @_vote VOTE_ABSTAIN

  _vote_member: (e) =>
    $(e.target).find('.b-catalog_entry').yellowFade()
    @_vote $(e.target).data('variant')

  _vote_click: (e) =>
    return if in_new_tab(e)
    if @_is_started()
      $(e.target).closest('.match-member').callRemote()
    false

  # private functions
  _vote: (vote) ->
    @_set_vote vote
    if @_next_match_id()
      delay(500).then => @_next_not_voted_match()

  _is_started: ->
    @model.state == 'started'

  _set_vote: (vote) ->
    @round_view.set_vote @model.id, vote
    @vote.vote = vote

    @$left
      .toggleClass('voted', vote == VOTE_LEFT)
      .toggleClass('unvoted', !!(vote && vote != VOTE_LEFT))
    @$right
      .toggleClass('voted', vote == VOTE_RIGHT)
      .toggleClass('unvoted', !!(vote && vote != VOTE_RIGHT))

    @$('.invitation').toggle !vote
    @$('.vote-voted').toggle(!!(vote && vote != VOTE_ABSTAIN))
    @$('.vote-abstained').toggle vote == VOTE_ABSTAIN

    @$('.thanks').toggle !!(vote && !@_next_match_id())
    @$('.action .abstain').toggleClass 'hidden', vote == VOTE_ABSTAIN
    @$('.action .to-next-not-voted').toggleClass 'hidden', !@_next_match_id()

  _next_match_id: ->
    @round_view.next_not_voted_match_id(@model.id)
