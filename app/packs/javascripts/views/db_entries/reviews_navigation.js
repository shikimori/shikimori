import { bind, memoize } from 'shiki-decorators';
import TinyUri from 'tiny-uri';
import delay from 'delay';

import View from '@/views/application/view';
import axios from '@/utils/axios';
import inNewTab from '@/utils/in_new_tab';

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

    $(document).one('turbolinks:before-cache', this.deselectActiveState);
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
  navigationBlockClick(e) {
    const opinion = e.currentTarget.getAttribute('data-opinion');

    if (this.isPreview && opinion != this.activeState.opinion) {
      if (inNewTab(e)) { return; }
      e.preventDefault();
    }
    this.selectOpinion(opinion);
  }

  @bind
  deselectActiveState() {
    this.deselectState(this.activeState, true);
  }

  selectOpinion(opinion, isSkipHistory = false) {
    const state = this.findState(opinion);
    if (state.isActive) { return; }

    const isMakePriorStatePending = this.activeState && !this.isContentLoaded(state);
    const priorState = this.deselectState(this.activeState, !isMakePriorStatePending);

    state.isActive = true;
    state.navigationNode.classList.add('is-active');

    if (!isMakePriorStatePending) {
      state.contentNode.classList.add('is-active');
    }

    if (!this.isPreview && !isSkipHistory) {
      this.replaceHistoryState(state);
    }

    if (!this.isContentLoaded(state)) {
      this.loadContent(state, priorState);
    }

    this.ellipsisFixes();
  }

  deselectState(state, isDeselectContent) {
    if (!state) { return null; }

    state.isActive = false;
    state.navigationNode.classList.remove('is-active');
    if (isDeselectContent) {
      state.contentNode.classList.remove('is-active');
    }

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

  isContentLoaded(state) {
    return state.contentNode.childElementCount > 0;
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

    (priorState || state).contentNode.classList.add('b-ajax');
    state.isLoading = true;

    const [{ data }] = await Promise.all([
      axios.get(this.fetchUrl(state.opinion, this.isPreview)),
      delay(350)
    ]);

    state.contentNode.innerHTML = data.content + (data.postloader || '');
    (priorState || state).contentNode.classList.remove('b-ajax');
    state.isLoading = false;

    if (priorState) {
      priorState.contentNode.classList.remove('is-active');
      state.contentNode.classList.add('is-active');
    }
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
