import Turbolinks from 'turbolinks';

import UserRatesTracker from 'services/user_rates/tracker';
import ajaxCacher from 'services/ajax_cacher';
import flash from 'services/flash';

import DynamicParser from 'dynamic_elements/_parser';

import axios from 'helpers/axios';
import inNewTab from 'helpers/in_new_tab';

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

    this.pagesLimit = 15;
    this.pageChange = {};

    this.$content.on(
      'postloader:before',
      (_e, $content, $data) => this._onPageLoadByScroll($content, $data)
    );
    this.$pagination
      .on('click', '.link', e => this._onPaginationLinkClick(e))
      .on('click', '.no-hover', e => this._onPaginationPageSelect(e));

    this.filters = new Animes.CatalogFilters(
      basePath,
      window.location.href,
      this.load.bind(this)
    );

    this.collectionSearch = $('.l-top_menu-v2 .global-search').view();
    const oldProcessResponse = this.collectionSearch._processResponse;
    this.collectionSearch._processResponse = this._processResponse.bind(this);

    // restore original search._processResponse
    $(document).one(
      'turbolinks:before-cache',
      () => this.collectionSearch._processResponse = oldProcessResponse
    );
  }

  get isPagesLimit() {
    return this.$content.children().length >= this.pagesLimit;
  }

  load(url) {
    window.history.pushState({ turbolinks: true, url }, '', url);

    this.filters.parse(url);
    this._fetch(url);

    this.collectionSearch.$root.data('search_url', url.replace(/\/page\/\d+/, ''));
  }

  // events
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

  _onPageLoadByScroll($content, data) {
    this.$linkCurrent.html(this.$linkCurrent.html().replace(/-\d+|$/, `-${data.page}`));
    this.$linkTitle.html(this.$linkTitle.data('text'));
    this.$linkTotal.html(data.pages_count);

    this.$linkPrev.attr({
      href: data.prev_page_url || '',
      action: data.prev_page_url
    });

    this.$linkNext.attr({
      href: data.next_page_url || '',
      action: data.next_page_url
    });

    this.$linkPrev.toggleClass('disabled', !data.prev_page_url);
    this.$linkNext.toggleClass('disabled', !data.next_page_url);

    if (this.isPagesLimit) {
      $content.find('.b-postloader').data({ locked: true });
    }

    // this.$content.process(data.JS_EXPORTS)
  }

  // private methods
  _changePage(isRollback) {
    const value = parseInt(this.pageChange.$input.val()) || 1;

    this.$linkCurrent.removeClass('active');

    if (isRollback || (value === this.pageChange.priorValue)) {
      this.$linkCurrent.html(this.pageChange.priorValue);
    } else {
      const $link = this.$linkNext
        .add(this.$linkPrev)
        .filter(':not(.disabled)')
        .first();

      this.$linkCurrent.html(value);
      this.load($link.attr('href').replace(/\/\d+$/, `/${value}`));
    }

    this.pageChange.$input = null;
  }

  async _fetch(url) {
    let absoulteUrl = url;

    if (url.indexOf(`${window.location.protocol}//${window.location.host}`) === -1) {
      absoulteUrl = `${window.location.protocol}//${window.location.host}${url}`;
    }

    const cachedData = ajaxCacher.get(absoulteUrl);
    if (cachedData) {
      this._processResponse(cachedData, absoulteUrl);
      return;
    }

    this.$content.addClass('b-ajax');

    const { data } = await axios
      .get(absoulteUrl)
      .catch(({ response }) => {
        if (response.status === 451) { // || response.data === 'age_restricted'
          Turbolinks.visit(window.location.href);
        } else {
          flash.error(
            I18n.t('frontend.lib.paginated_catalog.please_try_again_later')
          );
        }
      });

    ajaxCacher.push(absoulteUrl, data);

    if (window.location.href === absoulteUrl) {
      this._processResponse(data, absoulteUrl);
      this.$content.removeClass('b-ajax');
    }
  }

  _processResponse(data, url) {
    document.title = `${data.title}`;
    const $content = $(data.content);

    // using Object.clone cause UserRatesTracker changes data in its its argument
    UserRatesTracker.track(Object.clone(data.JS_EXPORTS), $content);

    // for cutted_covers
    if (this.$content.data('dynamic')) {
      this.$content.addClass(DynamicParser.PENDING_CLASS);
    }
    this.$content.html($content).process();

    $('.head h1').html(data.title);
    if (data.notice) {
      $('.head .notice').html(data.notice);
    }

    this.$linkCurrent.html(data.page);
    this.$linkTotal.html(data.pages_count);

    this.$linkPrev.attr({ href: data.prev_page_url || '', action: data.prev_page_url });
    if (data.prev_page_url) {
      this.$linkPrev.removeClass('disabled');
    } else {
      this.$linkPrev.addClass('disabled');
    }

    this.$linkNext.attr({ href: data.next_page_url || '', action: data.next_page_url });
    if (data.next_page_url) {
      this.$linkNext.removeClass('disabled');
    } else {
      this.$linkNext.addClass('disabled');
    }

    this.$pagination.toggle(
      !(this.$linkNext.hasClass('disabled') && this.$linkPrev.hasClass('disabled'))
    );

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
}
