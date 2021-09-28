import Turbolinks from 'turbolinks';
import { flash } from 'shiki-utils';
import { bind } from 'shiki-decorators';

import UserRatesTracker from '@/services/user_rates/tracker';
import ajaxCacher from '@/services/ajax_cacher';

import DynamicParser from '@/dynamic_elements/_parser';
import CatalogFilters from '@/views/animes/catalog_filters';

import inNewTab from '@/utils/in_new_tab';

export default class PaginatedCatalog {
  constructor(basePath) {
    this.$content = $('.l-content');
    this.$pagination = $('.pagination');

    this.$linkCurrent = this.$pagination.find('.link-current');
    this.$linkNext = this.$pagination.find('.link-next');
    this.$linkPrev = this.$pagination.find('.link-prev');
    this.$linkTotal = this.$pagination.find('.link-total');
    this.$linkTitle = this.$pagination.find('.link-title');

    if (this.$linkNext.hasClass('disabled') && this.$linkPrev.hasClass('disabled')) {
      this.$pagination.hide();
    }

    this.pageChange = {};

    this.$content
      .on('postloader:before', this._onPageLoadByScroll);
    this.$pagination
      .on('click', '.link', this._onPaginationLinkClick)
      .on('click', '.no-hover', this._onPaginationPageSelect);

    this.filters =
      new CatalogFilters(basePath, window.location.href, this.load);
  }

  @bind
  load(url) {
    window.history.pushState({ turbolinks: true, url }, '', url);

    this.filters.parse(url);
    this._fetch(url);
  }

  // events
  @bind
  _onPaginationLinkClick(e) {
    if (inNewTab(e)) { return; }

    e.preventDefault();

    const $link = $(e.target);
    if ($link.hasClass('disabled')) { return; }

    if ($(window).scrollTop() > 400) {
      $.scrollTo('.head');
    }

    this.load($link.attr('href'));
  }

  @bind
  _onPaginationPageSelect({ currentTarget }) {
    const $link = $(currentTarget).find('.link-current');

    if ($link.has('input').length) { return; }

    this.pageChange.priorValue = parseInt($link.html());
    this.pageChange.maxValue = parseInt(this.$linkTotal.html());
    $link
      .addClass('active')
      .html(
        `<input type='number' min='1' max='${this.pageChange.maxValue}' value='${this.pageChange.priorValue}' />`
      );

    this.pageChange.$input = $link
      .children()
      .focus()
      .on('blur', () => this._changePage(false))
      .on('keydown', ({ keyCode }) => {
        if (keyCode === 27) {
          this._changePage(true);
        }
      })
      .on('keypress', ({ keyCode }) => {
        if (keyCode === 13) {
          this._changePage(false);
        }
      });
  }

  @bind
  _onPageLoadByScroll(_e, $content, data) {
    const pages = this.$linkCurrent.html().split('-').map(parseInt);
    const { page: currentPage, pages_count: pagesCount } = data;
    const isLastPage = currentPage === pagesCount;

    pages[1] = currentPage;

    this.$linkCurrent.html(pages.join('-'));
    this.$linkTitle.html(this.$linkTitle.data('text'));
    this.$linkTotal.html(pagesCount);

    this.$linkNext
      .attr('href', isLastPage ? null : this.filters.compile(currentPage + 1))
      .toggleClass('disabled', isLastPage);

    // this.$content.process(data.JS_EXPORTS)
  }

  // private methods
  _changePage(isRollback) {
    const currentPage = parseInt(this.pageChange.$input.val()) || 1;

    this.$linkCurrent.removeClass('active');

    if (isRollback || (currentPage === this.pageChange.priorValue)) {
      this.$linkCurrent.html(this.pageChange.priorValue);
    } else {
      this.$linkCurrent.html(currentPage);
      this.load(this.filters.compile(currentPage));
    }

    this.pageChange.$input = null;
  }

  async _fetch(url) {
    let absoulteUrl = url;

    if (url.indexOf(`${window.location.protocol}//${window.location.host}`) === -1) {
      absoulteUrl = `${window.location.protocol}//${window.location.host}${url}`;
    }

    this._showAjax();
    const { data, status } = await ajaxCacher.fetch(absoulteUrl);
    this._hideAjax();

    if (status !== 200) {
      if (status === 451) {
        window.location.reload();
      } else {
        flash.error(I18n.t('frontend.lib.please_try_again_later'));
      }
      return;
    }

    if (
      window.location.href === absoulteUrl ||
      decodeURI(window.location.href) == absoulteUrl
    ) {
      this._processResponse(data, absoulteUrl);
    }
  }

  _processResponse(data, url) {
    const {
      page: currentPage,
      pages_count: pagesCount,
      content,
      title,
      notice
    } = data;
    const isFirstPage = currentPage === 1;
    const isLastPage = currentPage === pagesCount;

    const $content = $(content);

    // using Object.clone cause UserRatesTracker changes data in its its argument
    UserRatesTracker.track(Object.clone(data.JS_EXPORTS), $content);

    // for cutted_covers
    if (this.$content.data('dynamic')) {
      this.$content.addClass(DynamicParser.PENDING_CLASS);
    }
    this.$content.html($content).process();

    if (data.title) {
      $('.head h1').html(title);
      document.title = `${title}`;
    }
    if (data.notice) {
      $('.head .notice').html(notice);
    }

    this.$linkCurrent.html(currentPage);
    this.$linkTotal.html(pagesCount);

    this.$linkPrev
      .attr('href', isFirstPage ? null : this.filters.compile(currentPage - 1))
      .toggleClass('disabled', isFirstPage);

    this.$linkNext
      .attr('href', isLastPage ? null : this.filters.compile(currentPage + 1))
      .toggleClass('disabled', isLastPage);

    this.$pagination.toggle(!isLastPage || !isFirstPage);
    this.$content.trigger('ajax:success');

    if (url) {
      // google analytics
      if ('_gaq' in window) {
        window._gaq.push(['_trackPageview', url]);
      }
      // yandex metrika
      if ('yaCounter7915231' in window) {
        window.yaCounter7915231.hit(url);
      }
    }
  }

  _showAjax() {
    this.$content.addClass('b-ajax');
  }

  _hideAjax() {
    this.$content.removeClass('b-ajax');
  }
}
