import ContestRound from 'views/contests/round';

page_load('contests_show', () => {
  if (!$('.contest.started').length) {
    return;
  }

  new ContestRound($('.contest_round'), gon.votes);
});
