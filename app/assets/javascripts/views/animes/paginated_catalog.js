import Turbolinks from 'turbolinks';
import { CancelToken } from 'axios';

import UserRatesTracker from 'services/user_rates/tracker';
import axios from 'helpers/axios';
import ajaxCacher from 'services/ajax_cacher';
import flash from 'services/flash';
import DynamicParser from 'dynamic_elements/_parser';
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
      this._onFilterPageChange.bind(this)
    );

    this.collectionSearch = $('.l-top_menu-v2 .global-search').view();
    const oldProcessResponse = this.collectionSearch._processResponse;
    this.collectionSearch._processResponse = this._processAjaxContent;

    // restore original search._processResponse
    $(document).one(
      'turbolinks:before-cache',
      () => this.collectionSearch._processResponse = oldProcessResponse
    );
  }

  get isPagesLimit() {
    return this.$content.children().length >= this.pagesLimit;
  }

  // events
  _onFilterPageChange(url) {
    window.history.pushState({ turbolinks: true, url }, '', url);

    this.filters.parse(url);
    this._fetch(url);

    this.collectionSearch.$root.data({ search_url: url });
  }

  _onPaginationLinkClick(e) {
    if (inNewTab(e)) { return; }

    const $link = $(e.target);

    if ($link.hasClass('disabled')) {
      e.preventDefault();
    }
    if ($(window).scrollTop() > 400) {
      $.scrollTo('.head');
    }
  }

  _onPaginationPageSelect() {
    if (this.$linkCurrent.has('input').length) { return; }

    this.pageChange.priorValue = parseInt(this.$linkCurrent.html());
    this.pageChange.maxValue = parseInt(this.$linkTotal.html());
    this.$linkCurrent.html(
      `<input type='number' min='1' max='${this.pageChange.maxValue}' value='${this.pageChange.priorValue}' />`
    );

    this.pageChange.$input = this.$linkCurrent
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

    if (isRollback || (value === this.pageChange.priorValue)) {
      this.pageChange.$input.parent().html(this.pageChange.priorValue);
    } else {
      const $link = this.$linkNext
        .add(this.$linkPrev)
        .filter(':not(.disabled)')
        .first();

      Turbolinks.visit($link.attr('href').replace(/\/\d+$/, `/${value}`));
      this.pageChange.$input.parent().html(value);
    }

    this.pageChange.$input = null;
  }

  _fetch(url) {
    // let url = url;

    // if (url.indexOf(window.location.protocol + '//' + window.location.host) === -1) {
    //   url = window.location.protocol + '//' + window.location.host + url;
    // }

    if (this.pendingRequest) {
      this.pendingRequest.cancel();
    }

    const cachedData = ajaxCacher.get(url);
    if (cachedData) {
      this._processAjaxContent(cachedData, url);
      return;
    }

    this.$content.addClass('b-ajax');
    this.pendingRequest = CancelToken.source();

    axios
      .get(url, { cancelToken: this.pendingRequest.token })
      .then(({ data }) => {
        ajaxCacher.push(url, data);
        this._processAjaxContent(data, url);
      })
      .catch(({ response }) => {
        if (response.status === 451) { // || response.data === 'age_restricted'
          Turbolinks.visit(window.location.href);
        } else {
          flash.error(
            I18n.t('frontend.lib.paginated_catalog.please_try_again_later')
          );
        }
      });

    this.pendingRequest = null;
    this.$content.removeClass('b-ajax');

    return;
    $.ajax({
      url,
      dataType: 'json',
      beforeSend: xhr => {
        this.$content.addClass('b-ajax');

        if (this.pendingRequest) {
          if ('abort' in this.pendingRequest) {
            this.pendingRequest.abort();
          } else {
            this.pendingRequest.aborted = true;
          }
          this.pendingRequest = null;
        }

        if (this.pendingRequest) {
          xhr.abort();
          return;
        }

        const cachedData = ajaxCacher.get(url);

        if (cachedData) {
          xhr.abort();

          if ('abort' in cachedData && 'setRequestHeader' in cachedData) {
          } else {
            this._processAjaxContent(cachedData, url);
            this.pendingRequest = null;
            this.$content.removeClass('b-ajax');
          }
        } else {
          this.pendingRequest = xhr;
        }
      },


      complete: _xhr => {
        this.pendingRequest = null;
        return this.$content.removeClass('b-ajax');
      },

      error(xhr, _status, _error) {
        if (xhr && xhr.responseText && xhr.responseText.includes('age-restricted-warning')) {
          Turbolinks.visit(window.location.href);
        } else {
          flash.error(I18n.t('frontend.lib.paginated_catalog.please_try_again_later'));
        }
      }
    });
  }

  _processAjaxContent(data, url) {
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
    $('.head .notice').html(data.notice);

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
