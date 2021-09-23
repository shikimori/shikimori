import { bind } from 'shiki-decorators';
import View from '@/views/application/view';

export class ReviewsNavigation extends View {
  initialize() {
    this.$navigationBlocks = this.$('.navigation-block');
    const $reviewGroups = this.$node.next().children('.reviews-group');

    this.states = this.$navigationBlocks.toArray().map((node, index) => ({
      navigationNode: node,
      reviewsNode: $reviewGroups[index],
      opinion: node.getAttribute('data-opinion'),
      isActive: false,
      isPendingContent: $reviewGroups[index].getAttribute('pending-content')
    }));

    this.$navigationBlocks.on('click', this.navigationBlockClick);

    this.selectOpinion(this.$node.data('initial-opinion'));
  }

  @bind
  navigationBlockClick({ currentTarget }) {
    this.selectOpinion(currentTarget.getAttribute('data-opinion'));
  }

  selectOpinion(opinion) {
    const state = this.findEntry(opinion);
    if (state.isActive) { return; }

    this.deselectActiveOpinion();

    state.isActive = true;
    state.navigationNode.classList.add('is-active');

    if (this.isNoContentLoaded(state.reviewsNode)) {
      this.loadContent(state);
    }

    this.ellipsisFixes();
  }

  deselectActiveOpinion() {
    const state = this.states.find(v => v.isActive);
    if (!state) { return; }

    state.isActive = false;
    state.navigationNode.classList.remove('is-active');
  }

  findEntry(opinion) {
    return this.states.find(state => state.opinion === opinion);
  }

  ellipsisFixes() {
    this.$navigationBlocks
      .filter('[data-ellispsis-allowed]')
      .removeClass('is-ellipsis');

    this.$navigationBlocks
      .filter('[data-ellispsis-allowed]:not(.is-active)')
      .last()
      .addClass('is-ellipsis');
  }

  isNoContentLoaded(node) {
    return node.childElementCount === 0;
  }

  loadContent(state) {
    console.log('loadContent', state);
  }
}
