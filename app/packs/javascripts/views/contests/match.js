import delay from 'delay';

import View from '@/views/application/view';
import inNewTab from '@/utils/in_new_tab';

const VOTE_LEFT = 'left';
const VOTE_RIGHT = 'right';
const VOTE_ABSTAIN = 'abstain';

export default class ContestMatch extends View {
  initialize(vote, roundView) {
    this.roundView = roundView;
    this.model = this.$root.data('model');
    this.vote = vote || {};

    this.$left = this.$('.match-member[data-variant="left"]');
    this.$right = this.$('.match-member[data-variant="right"]');

    this.$('.next-match').on('click', () => this._toNextMatch());
    this.$('.prev-match').on('click', () => this._toPrevMatch());
    this.$('.action .to-next-not-voted').on('click', () => this._toNextNotVotedMatch());
    this.$('.match-member img').on('click', e => this._voteClick(e));

    this.$('.match-member').on('ajax:success', e => this._voteMember(e));
    this.$('.action .abstain').on('ajax:success', () => this._abstain());

    if (this.isStarted) {
      this.$('.match-member .b-catalog_entry').hover(
        e => {
          if (this.vote.vote) { return; }

          this.$('.match-member').addClass('unhovered');
          $(e.target)
            .closest('.match-member')
            .removeClass('unhovered')
            .addClass('hovered');
        },
        () =>
          this.$('.match-member').removeClass('hovered unhovered')
      );

      this._setVote(this.vote.vote);
    }

    this.initialized = true;
  }

  get isStarted() {
    return this.model.state === 'started';
  }

  // handlers
  _toNextMatch() {
    this.roundView.switchMatch(this.roundView.nextMatchId(this.model.id));
  }

  _toPrevMatch() {
    this.roundView.switchMatch(this.roundView.prevMatchId(this.model.id));
  }

  _toNextNotVotedMatch() {
    this.roundView.switchMatch(this._nextMatchId());
  }

  _abstain() {
    this._vote(VOTE_ABSTAIN);
  }

  _voteMember({ target }) {
    $(target).find('.b-catalog_entry').yellowFade();
    this._vote($(target).data('variant'));
  }

  _voteClick(e) {
    if (inNewTab(e)) { return; }

    e.preventDefault();
    e.stopImmediatePropagation();

    if (this.isStarted) {
      $(e.target).closest('.match-member').callRemote();
    }
  }

  // private functions
  async _vote(vote) {
    this._setVote(vote);

    if (this._nextMatchId()) {
      await delay(500);
      this._toNextNotVotedMatch();
    }
  }

  _setVote(vote) {
    this.roundView.setVote(this.model.id, vote);
    this.vote.vote = vote;

    this.$left
      .toggleClass('voted', vote === VOTE_LEFT)
      .toggleClass('unvoted', !!(vote && (vote !== VOTE_LEFT)));
    this.$right
      .toggleClass('voted', vote === VOTE_RIGHT)
      .toggleClass('unvoted', !!(vote && (vote !== VOTE_RIGHT)));

    this.$('.invitation').toggle(!vote);
    this.$('.vote-voted').toggle(!!(vote && (vote !== VOTE_ABSTAIN)));
    this.$('.vote-abstained').toggle(vote === VOTE_ABSTAIN);

    this.$('.thanks').toggle(!!(vote && !this._nextMatchId()));
    this.$('.action .abstain').toggleClass('hidden', vote === VOTE_ABSTAIN);
    this.$('.action .to-next-not-voted').toggleClass('hidden', !this._nextMatchId());
  }

  _nextMatchId() {
    return this.roundView.nextNotVotedMatchId(this.model.id);
  }
}
