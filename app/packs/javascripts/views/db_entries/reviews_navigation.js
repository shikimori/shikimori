import { bind } from 'shiki-decorators';
import View from '@/views/application/view';

const NAVIGATION_BLOCK_SELECTOR = '.navigation-block';

export class ReviewsNavigation extends View {
  initialize() {
    this.$navigationBlocks = this.$(NAVIGATION_BLOCK_SELECTOR);

    this.$navigationBlocks.on('click', this.pickOpinionNode);

    const dataInitialOpinion = this.$node.data('initial-opinion') || "''"; // eslint-disable-line quotes
    this.pickOpinionNode({
      currentTarget: this.$navigationBlocks.filter(`[data-opinion=${dataInitialOpinion}]`)[0]
    });
  }

  @bind
  pickOpinionNode({ currentTarget }) {
    if (currentTarget.classList.contains('is-active')) {
      return;
    }

    this.$navigationBlocks
      .filter('.is-active')
      .removeClass('is-active');

    currentTarget.classList.add('is-active');
    // console.log(currentTarget)

    this.$navigationBlocks
      .filter('[data-ellispsis-allowed]')
      .removeClass('is-ellipsis');

    this.$navigationBlocks
      .filter('[data-ellispsis-allowed]:not(.is-active)')
      .last()
      .addClass('is-ellipsis');
  }
}
