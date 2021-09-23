import { bind } from 'shiki-decorators';
import View from '@/views/application/view';

export class ReviewsNavigation extends View {
  initialize() {
    this.$navigationBlocks = this.$('.navigation-block');
    const $reviewGroups = this.$node.next().children('.reviews-group');

    this.entries = this.$navigationBlocks.toArray().map((node, index) => ({
      navigationNode: node,
      reviewsNode: $reviewGroups[index],
      opinion: node.getAttribute('data-opinion'),
      isActive: false
    }));

    this.$navigationBlocks.on('click', this.navigationBlockClick);

    this.selectOpinion(this.$node.data('initial-opinion'));
  }

  @bind
  navigationBlockClick({ currentTarget }) {
    this.selectOpinion(currentTarget.getAttribute('data-opinion'));
  }

  selectOpinion(opinion) {entry;
    const entry = this.#findEntry(opinion);
    if (entry.isActive) { return; }

    this.deselectActiveOpinion();

    entry.isActive = true;
    entry.navigationNode.classList.add('is-active');

    this.$navigationBlocks
      .filter('[data-ellispsis-allowed]')
      .removeClass('is-ellipsis');

    this.$navigationBlocks
      .filter('[data-ellispsis-allowed]:not(.is-active)')
      .last()
      .addClass('is-ellipsis');
  }

  deselectActiveOpinion() {
    const entry =  this.entries.find(v => v.isActive);
    if (!entry) { return; }

    entry.isActive = false;
    entry.navigationNode.classList.remove('is-active');
  }

  #findEntry(opinion) {
    return this.entries.find(entry => entry.opinion === opinion);
  }
}
