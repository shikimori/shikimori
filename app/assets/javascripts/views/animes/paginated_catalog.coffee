import CollectionSearch from 'views/application/collection_search'
import UserRatesTracker from 'services/user_rates/tracker'
import Turbolinks from 'turbolinks'

import ajaxCacher from 'services/ajax_cacher'
import flash from 'services/flash'
import DynamicParser from 'dynamic_elements/_parser'
import inNewTab from 'helpers/in_new_tab'

export default class PaginatedCatalog
  constructor: (base_catalog_path) ->
    @$content = $('.l-content')
    @$pagination = $('.pagination')
    @$link_current = @$pagination.find('.link-current')
    @$link_next = @$pagination.find('.link-next')
    @$link_prev = @$pagination.find('.link-prev')
    @$link_total = @$pagination.find('.link-total')
    @$link_title = @$pagination.find('.link-title')

    if @$link_next.hasClass('disabled') && @$link_prev.hasClass('disabled')
      @$pagination.hide()

    @pages_limit = 15

    @page_change = {}

    @$content.on 'postloader:before', @_page_loaded_by_scroll
    @$pagination.on 'click', '.link', @_pagination_link_click
    @$pagination.on 'click', '.no-hover', @_pagination_page_select

    @filters = new Animes.CatalogFilters(
      base_catalog_path,
      location.href,
      @_filter_page_change
    )

    @collection_search = $('.l-top_menu-v2 .global-search').view()
    old_process_response = @collection_search._process_response
    @collection_search._process_response = @_process_ajax_content

    # restore search._process_response
    $(document).one 'turbolinks:before-cache', =>
      @collection_search._process_response = old_process_response

  # bind_history: =>
  #   $(window).off 'popstate', @_history_page_changed
  #   $(window).on 'popstate', @_history_page_changed

  #   $(window).one 'page:before-unload', =>
  #     $(window).off 'popstate', @_history_page_changed

  _filter_page_change: (url) =>
    window.history.pushState { turbolinks: true, url: url }, '', url
    @_history_page_changed()

    @collection_search.$root.data search_url: url

  _history_page_changed: =>
    url = location.href

    @filters.parse(url)# if url != @filters.last_compiled
    @_fetch_ajax_content(url, true)#.call this, url, null, true

  _pagination_link_click: (e) ->
    return if inNewTab(e)
    $link = $(e.target)

    if $link.hasClass 'disabled'
      false
    else
      $.scrollTo '.head' if $(window).scrollTop() > 400

  _page_loaded_by_scroll: (e, $content, data) =>
    @$link_current.html @$link_current.html().replace(/-\d+|$/, '-' + data.page)
    @$link_title.html @$link_title.data('text')
    @$link_total.html data.pages_count

    @$link_prev.attr
      href: data.prev_page_url || ''
      action: data.prev_page_url

    @$link_next.attr
      href: data.next_page_url || ''
      action: data.next_page_url

    @$link_prev.toggleClass 'disabled', !data.prev_page_url
    @$link_next.toggleClass 'disabled', !data.next_page_url

    # после pages_limit отключаем postloader (слишком много контента на странице оказывается и начинает тормозить)
    if @_is_pages_limit()
      $content.find('.b-postloader').data locked: true

    # @$content.process data.JS_EXPORTS

  # наступил ли лимит прокрутки страниц?
  _is_pages_limit: ->
    @$content.children().length >= @pages_limit

  _pagination_page_select: (e) =>
    $link = $(e.currentTarget).find('.link-current')
    return if $link.has('input').length

    @page_change.prior_value = parseInt @$link_current.html()
    @page_change.max_value = parseInt @$link_total.html()
    $link.html(
      "<input type='number' min='1' max='#{@page_change.max_value}' value='#{@page_change.prior_value}' />"
    )

    @page_change.$input = $link
      .children()
      .focus()
      .on 'blur', => @_apply_page false
      .on 'keydown', (e) =>
        if e.keyCode == 27
          @_apply_page true

      .on 'keypress', (e) =>
        if e.keyCode == 13
          @_apply_page false

  # применения выбора страницы
  _apply_page: (rollback) ->
    value = parseInt(@page_change.$input.val()) || 1

    if rollback || value == @page_change.prior_value
      @page_change.$input.parent().html @page_change.prior_value

    else
      $link = @$link_next
        .add(@$link_prev)
        .filter(':not(.disabled)')
        .first()

      Turbolinks.visit $link.attr('href').replace(/\/\d+$/, "/#{value}")
      @page_change.$input.parent().html value

    @page_change.$input = null

  # загрузка ajax'ом контента каталога
  _fetch_ajax_content: (url, break_pending) ->
    if url.indexOf(location.protocol + '//' + location.host) == -1
      url = location.protocol + '//' + location.host + url

    $.ajax
      url: url
      dataType: 'json'
      beforeSend: (xhr) =>
        @$content.addClass('b-ajax')

        if @pending_request && break_pending
          if 'abort' in pending_request
            @pending_request.abort()
          else
            @pending_request.aborted = true
          @pending_request = null

        if @pending_request # $(@).hasClass("disabled")
          return xhr.abort()

        cached_data = ajaxCacher.get(url)

        if cached_data
          xhr.abort()

          if 'abort' of cached_data && 'setRequestHeader' of cached_data
            # cached_data
            #   .success(xhr.success)
            #   .complete(xhr.complete)
            #   .error(xhr.error)
          else
            @_process_ajax_content cached_data, url
            @pending_request = null
            @$content.removeClass('b-ajax')

        else
          pending_request = xhr

        # если подгрузка следующей страницы при прокруте, то никаких индикаций загрузки не надо
        # return if $postloader
        # if $(".ajax").children().length isnt 1 or $(".ajax").children(".ajax-loading").length != 1
        #   $(".ajax:not(.no-animation), .ajax-opacity").animate opacity: 0.3
        #   $(".ajax.no-animation").css opacity: 0.3
        # $.cursorMessage()

      success: (data, status, xhr) =>
        ajaxCacher.push url, data
        return if 'aborted' of xhr && xhr.aborted
        @_process_ajax_content data, url

      complete: (xhr) =>
        @pending_request = null
        @$content.removeClass('b-ajax')

      error: (xhr, status, error) ->
        if xhr?.responseText?.includes('age-restricted-warning')
          Turbolinks.visit location.href
        else
          flash.error(I18n.t('frontend.lib.paginated_catalog.please_try_again_later'))

  # обработка контента, полученного от аякс-запроса
  _process_ajax_content: (data, url) =>
    document.title = "#{data.title}"
    $content = $(data.content)

    # используем Object.clone т.к. UserRatesTracker изменяет передаваемый в него массив
    UserRatesTracker.track Object.clone(data.JS_EXPORTS), $content

    # чтобы cutted_covers сработал
    if @$content.data 'dynamic'
      @$content.addClass(DynamicParser.PENDING_CLASS)
    @$content.html($content).process()

    $('.head h1').html data.title
    $('.head .notice').html data.notice

    @$link_current.html data.page
    @$link_total.html data.pages_count

    @$link_prev.attr(href: data.prev_page_url || '', action: data.prev_page_url)
    if data.prev_page_url
      @$link_prev.removeClass 'disabled'
    else
      @$link_prev.addClass 'disabled'

    @$link_next.attr(href: data.next_page_url || '', action: data.next_page_url)
    if data.next_page_url
      @$link_next.removeClass 'disabled'
    else
      @$link_next.addClass 'disabled'

    @$pagination.toggle !(@$link_next.hasClass('disabled') && @$link_prev.hasClass('disabled'))

    # отслеживание страниц в гугл аналитике и яндекс метрике
    if '_gaq' of window
      _gaq.push [
        '_trackPageview'
        url
      ]
    if 'yaCounter7915231' of window
      yaCounter7915231.hit url
