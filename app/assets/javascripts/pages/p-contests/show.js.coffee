page_load 'contests_show', ->
  if $('.contest.started').length
    new Contests.Round $('.contest_round'), gon.votes
