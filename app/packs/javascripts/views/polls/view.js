import axios from 'helpers/axios';
import View from 'views/application/view';
import JST from 'helpers/jst';
import { bind } from 'shiki-decorators';

const TEMPLATE = 'polls/poll';

export default class Poll extends View {
  initialize(model) {
    this.model = model;
    this._render();

    if (!this.canVote) { return; }

    this.$vote = this.$('.poll-actions .vote');
    this.$abstain = this.$('.poll-actions .abstain');
    this._toggleActions();

    this.$('.b-radio').on('click', this._radioClick);

    this.$vote.on('click', this._voteVariant);
    this.$abstain.on('click', this._abstain);
  }

  get canVote() {
    return window.SHIKI_USER.isSignedIn &&
      (this.model.state === 'started') &&
      !this.model.vote.is_abstained && !this.model.vote.variant_id;
  }

  get checkedRadio() {
    return this.$('input[type=radio]:checked')[0];
  }

  // handlers
  @bind
  _radioClick(e) {
    e.preventDefault();

    const $radio = $(e.currentTarget).find('input');
    $radio.prop({ checked: !$radio.prop('checked') });
    this._toggleActions();
  }

  @bind
  _voteVariant() {
    const variantId = parseInt(this.checkedRadio.value);
    const variant = this.model.variants.find(v => v.id === variantId);

    this.model.vote = { is_abstained: false, variant_id: variant.id };
    variant.votes_total += 1;

    this._vote(variant.vote_for_url);
  }

  @bind
  _abstain() {
    this.model.vote = { is_abstained: true, variant_id: null };
    this._vote(this.model.vote_abstain_url);
  }

  // private functions
  _render() {
    const $oldRoot = this.$root;
    this._setRoot(
      JST[TEMPLATE]({
        model: this.model,
        can_vote: this.canVote,
        bar_percent: this._variantPercent,
        bar_class: this._variantClass
      })
    );
    $oldRoot.replaceWith(this.$root);
  }

  async _vote(url) {
    this.$root.addClass('b-ajax');

    await axios.post(url);

    this.$root.removeClass('b-ajax');
    this._render();
  }

  _toggleActions() {
    if (this.checkedRadio) {
      this.$abstain.addClass('hidden');
      this.$vote.removeClass('hidden');
    } else {
      this.$abstain.removeClass('hidden');
      this.$vote.addClass('hidden');
    }
  }

  @bind
  _variantPercent(variant) {
    const totalVotes = this.model.variants.sum('votes_total');

    if (totalVotes === 0) {
      return 0;
    }
    return ((100.0 * variant.votes_total) / totalVotes).round(2);
  }

  @bind
  _variantClass(variant) {
    const votesPercent = this._variantPercent(variant);

    if ((votesPercent <= 80) && (votesPercent > 60)) {
      return 's1';
    } if ((votesPercent <= 60) && (votesPercent > 30)) {
      return 's2';
    } if (votesPercent <= 30) {
      return 's1';
    }
    return 's0';
  }
}
