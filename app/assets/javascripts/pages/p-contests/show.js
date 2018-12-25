import ContestRound from 'views/contests/round';

page_load('contests_show', () => {
  if (!$('.contest_round').length) {
    return;
  }

  new ContestRound($('.contest_round'), gon.votes);
});
