import axios from '@/helpers/axios';

import View from '@/views/application/view';
import ContestMatch from './match';

const NEXT_MATCH_SELECTOR =
  '.match-day .match-link.started:not(.voted-left):not(.voted-right):not(.voted-abstain)';
const STARTED_MATCH_SELECTOR = '.match-day .match-link.started';
const ANY_MATCH_SELECTOR = '.match-day .match-link';

export default class ContestRound extends View {
  initialize(votes) {
    this.model = this.$root.data('model');
    this.votes = votes || [];

    this.$matchContainer = this.$('.match-container');

    this._setVotes(this.votes);
    this.switchMatch(this._initialMatchId());

    this.$('.match-day .match-link').on('click', e =>
      this.switchMatch($(e.currentTarget).data('id'))
    );
  }

  // public functions
  switchMatch(matchId) {
    const $match = this._$matchLine(matchId);
    this.$matchContainer.addClass('b-ajax');

    axios
      .get($match.data('match_url'))
      .then(response => {
        this.$('.match-link.active').removeClass('active');
        $match.addClass('active');

        this._matchLoaded(matchId, response.data);
      });
  }

  setVote(matchId, vote) {
    this._$matchLine(matchId)
      .removeClass('voted-left voted-rigth voted-abstain')
      .addClass(`voted-${vote}`);
  }

  nextMatchId(matchId) {
    const index = this.model.matches.findIndex(v => v.id === matchId);
    return (this.model.matches[index + 1] || this.model.matches.first()).id;
  }

  prevMatchId(matchId) {
    const index = this.model.matches.findIndex(v => v.id === matchId);
    return (this.model.matches[index - 1] || this.model.matches.last()).id;
  }

  nextNotVotedMatchId(matchId) {
    const nextNotVotedMatch = this.votes.find(v => (v.match_id !== matchId) && !v.vote);
    return nextNotVotedMatch ? nextNotVotedMatch.match_id : null;
  }

  // private functions
  _setVotes(votes) {
    Object.forEach(votes, vote => {
      if (vote.vote) {
        this.setVote(vote.match_id, vote.vote);
      }
    });
  }

  _$matchLine(matchId) {
    return $(`.match-day .match-link[data-id=${matchId}]`);
  }

  _initialMatchId() {
    return (
      this.$root.data('match_id') ||
        this.$(NEXT_MATCH_SELECTOR).first().data('id') ||
        this.$(STARTED_MATCH_SELECTOR).first().data('id') ||
        this.$(ANY_MATCH_SELECTOR).first().data('id')
    );
  }

  _matchLoaded(matchId, html) {
    const $html = $(html).process();
    const $match = $html.filter('.b-contest_match');
    const vote = this.votes.find(v => v.match_id === matchId);

    this.$matchContainer
      .removeClass('b-ajax')
      .html($html);

    new ContestMatch($match, vote, this);

    const $firstMember = this.$('.match-members .match-member').first();
    if (!$firstMember.is(':appeared')) { $.scrollTo($firstMember); }

    const pageUrl = $match.data('page_url');
    if (pageUrl) {
      window.history.replaceState(
        { turbolinks: true, url: pageUrl },
        '',
        pageUrl
      );
    }
  }
}
