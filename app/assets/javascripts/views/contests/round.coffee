using 'Contests'
module.exports = class Contests.Round extends View
  initialize: (votes) ->
    @model = @$root.data('model')
    @votes = votes || {}

    @$match_container = @$ '.match-container'

    @_set_votes @votes
    @switch_match @_initial_match_id()

    @$('.match-day .match-link').on 'click', (e) =>
      @switch_match $(e.currentTarget).data('id')

  # public functions
  switch_match: (match_id) ->
    $match = @_$match_line match_id
    @$match_container.addClass 'b-ajax'

    axios
      .get($match.data('match_url'))
      .then (response) =>
        @$('.match-link.active').removeClass 'active'
        $match.addClass('active')

        @_match_loaded match_id, response.data

  set_vote: (match_id, vote) ->
    @_$match_line(match_id)
      .removeClass("voted-left voted-rigth voted-abstain")
      .addClass("voted-#{vote}")

  next_match_id: (match_id) ->
    index = @model.matches.findIndex (v) -> v.id == match_id
    (@model.matches[index+1] || @model.matches.first()).id

  prev_match_id: (match_id) ->
    index = @model.matches.findIndex (v) -> v.id == match_id
    (@model.matches[index-1] || @model.matches.last()).id

  next_not_voted_match_id: (match_id) ->
    @votes.find((v) -> v.match_id != match_id && !v.vote)?.match_id

  # private functions
  _set_votes: (votes) ->
    Object.forEach votes, (vote) =>
      @set_vote vote.match_id, vote.vote if vote.vote

  _$match_line: (match_id) ->
    $(".match-day .match-link[data-id=#{match_id}]")

  _initial_match_id: ->
    @$root.data('match_id') ||
      @$('.match-day .match-link.started').first().data('id') ||
      @$('.match-day .match-link').first().data('id')

  _match_loaded: (match_id, html) ->
    $match = $(html).process()
    vote = @votes.find (vote) -> vote.match_id == match_id

    @$('.match-container').removeClass('b-ajax').html($match)

    new Contests.Match($match, vote, @)

    $first_member = @$('.match-members .match-member').first()
    $.scrollTo $first_member unless $first_member.is(':appeared')

    page_url = $match.data('page_url')
    if Modernizr.history && page_url
      window.history.replaceState(
        { turbolinks: true, url: page_url },
        '',
        page_url
      )
