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
    @$('.action .abstain').on 'ajax:success', @_abstain

    if @_is_started()
      # подсветка по ховеру курсора
      @$('.match-member').hover(
        (e) =>
          return if @vote.vote
          @$('.match-member').addClass('unhovered')
          $(e.target).removeClass('unhovered').addClass('hovered')
        , =>
          @$('.match-member').removeClass('hovered unhovered')
      )

      @_set_vote @vote.vote

  # handlers
  _next_match: =>
    @round_view.switch_match @round_view.next_match_id(@model.id)

  _prev_match: =>
    @round_view.switch_match @round_view.prev_match_id(@model.id)

  _next_not_voted_match: =>
    @round_view.switch_match @round_view.next_not_voted_match_id(@model.id)

  _abstain: =>
    @_set_vote VOTE_ABSTAIN

  # private functions
  _is_started: ->
    @model.state == 'started'

  _set_vote: (vote) ->
    @round_view.set_vote @model.id, vote
    @vote.vote = vote

    @$left
      .toggleClass('voted', vote == VOTE_LEFT)
      .toggleClass('unvoted', vote != VOTE_LEFT)
    @$right
      .toggleClass('voted', vote == VOTE_RIGHT)
      .toggleClass('unvoted', vote != VOTE_RIGHT)

    @$('.invitation').toggle !vote
    @$('.vote-voted').toggle vote && vote != VOTE_ABSTAIN
    @$('.vote-abstained').toggle vote == VOTE_ABSTAIN

    @$('.thanks').toggle !@round_view.next_not_voted_match_id(@model.id)
    @$('.action .refrain').toggleClass 'hidden', vote == VOTE_ABSTAIN
    @$('.action .to-next').toggleClass 'hidden', !vote
