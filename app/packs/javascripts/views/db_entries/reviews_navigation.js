import { bind, memoize } from 'shiki-decorators';
import TinyUri from 'tiny-uri';

import View from '@/views/application/view';
import axios from '@/helpers/axios';

export class ReviewsNavigation extends View {
  initialize() {
    this.$navigations = this.$('.navigation-container > .navigation-node');
    this.$contents = this.$('.content-container > .content-node');
    this.initialPage = this.$node.data('initial_page');

    this.states = this.$navigations.toArray().map((node, index) => ({
      navigationNode: node,
      contentNode: this.$contents[index],
      opinion: node.getAttribute('data-opinion'),
      isActive: false,
      isLoading: false
    }));

    this.$navigations.on('click', this.navigationBlockClick);

    this.selectOpinion(this.initialOption, true);
  }

  @memoize
  get initialOption() {
    return this.$node.data('initial_opinion');
  }

  @memoize
  get fetchUrlBase() {
    return this.$node.data('fetch_url_base');
  }

  @memoize
  get isPreview() {
    return this.$node.data('is_preview') !== undefined;
  }

  get activeState() {
    return this.states.find(v => v.isActive);
  }

  @bind
  navigationBlockClick({ currentTarget }) {
    this.selectOpinion(currentTarget.getAttribute('data-opinion'));
  }

  selectOpinion(opinion, isSkipHistory) {
    const state = this.findState(opinion);
    if (state.isActive) { return; }

    const priorState = this.deselectState(this.activeState);

    state.isActive = true;
    state.navigationNode.classList.add('is-active');
    state.contentNode.classList.add('is-active');

    if (!this.isPreview && !isSkipHistory) {
      this.replaceHistoryState(state);
    }

    if (this.isNoContentLoaded(state)) {
      this.loadContent(state, priorState);
    }

    this.ellipsisFixes();
  }

  deselectState(state) {
    if (!state) { return null; }

    state.isActive = false;
    state.navigationNode.classList.remove('is-active');
    state.contentNode.classList.remove('is-active');

    return state;
  }

  findState(opinion) {
    return this.states.find(state => state.opinion === opinion);
  }


  ellipsisFixes() {
    this.$navigations
      .filter('[data-ellispsis-allowed]')
      .removeClass('is-ellipsis');

    this.$navigations
      .filter('[data-ellispsis-allowed]:not(.is-active)')
      .last()
      .addClass('is-ellipsis');
  }

  isNoContentLoaded(state) {
    return state.contentNode.childElementCount === 0;
  }

  fetchUrl(opinion, isPreview) {
    const url = opinion ?
      this.fetchUrlBase + '/' + opinion :
      this.fetchUrlBase;

    return isPreview ?
      new TinyUri(url).query.merge({ is_preview: true }).toString() :
      url;
  }

  replaceHistoryState(state) {
    const url = this.fetchUrl(state.opinion, false);
    window.history.replaceState({ turbolinks: true, url }, '', url);
  }

  async loadContent(state, priorState) {
    if (state.isLoading) { return; }

    state.contentNode.classList.add('b-ajax');
    state.isLoading = true;

    const { data } = await axios.get(this.fetchUrl(state.opinion, this.isPreview));

    state.contentNode.innerHTML = data.content + (data.postloader || '');
    state.contentNode.classList.remove('b-ajax');
    state.isLoading = false;

    $(state.contentNode).process(data.JS_EXPORTS);

    if (this.initialPage !== 1 && priorState) {
      this.cleanNonFirstPage(priorState);
    }
  }

  cleanNonFirstPage(state) {
    state.contentNode.innerHTML = '';
    this.initialPage = 1;
  }
}
