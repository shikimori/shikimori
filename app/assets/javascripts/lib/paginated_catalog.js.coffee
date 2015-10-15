class @PaginatedCatalog
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
    @$pagination.on 'click', '.link', @_link_click
    @$pagination.on 'click', '.no-hover', @_page_select

    @filters = new AnimeCatalogFilters base_catalog_path, location.href, @_filter_page_change

    #$(window).on 'popstate', =>
      #@filters.last_compiled = location.href

  #bind_history: =>
    #$(window).off 'popstate', @_history_page_changed
    #$(window).on 'popstate', @_history_page_changed

    #$(window).one 'page:before-unload', =>
      #$(window).off 'popstate', @_history_page_changed

  # выбраны какие-то фильтры, необходимо загрузить страницу
  _filter_page_change: (url) =>
    if Turbolinks.supported
      window.history.pushState { turbolinks: true, url: url }, '', url
      @_history_page_changed()
    else
      location.href = url

  # урл страницы изменён через history api
  _history_page_changed: =>
    url = location.href

    @filters.parse(url)# if url != @filters.last_compiled
    @_fetch_ajax_content(url, true)#.call this, url, null, true

  # клик по ссылке пагинации
  _link_click: (e) =>
    return if in_new_tab(e)
    $link = $(e.target)

    if $link.hasClass 'disabled'
      false
    else
      $.scrollTo '.head' if $(window).scrollTop() > 400

  # загружена следующая страница при скролле вниз
  _page_loaded_by_scroll: (e, $content, data) =>
    @$link_current.html @$link_current.html().replace(/-\d+|$/, "-" + data.current_page)
    @$link_title.html "Страницы"
    @$link_total.html data.total_pages

    @$link_prev.attr
      href: data.prev_page || ""
      action: data.prev_page

    @$link_next.attr
      href: data.next_page || ""
      action: data.next_page

    @$link_prev.toggleClass 'disabled', !data.prev_page
    @$link_next.toggleClass 'disabled', !data.next_page

    # после pages_limit отключаем postloader (слишком много контента на странице оказывается и начинает тормозить)
    if @_is_pages_limit()
      $content.find('.b-postloader').data locked: true

    @$content.process()

  # наступил ли лимит прокрутки страниц?
  _is_pages_limit: ->
    @$content.children().length >= @pages_limit

  # клик по блоку выбора страницы
  _page_select: (e) =>
    $link = $(e.currentTarget).find(".link-current")
    return if $link.has('input').length

    @page_change.prior_value = parseInt @$link_current.html()
    @page_change.max_value = parseInt @$link_total.html()
    $link.html "<input type='number' min='1' max='#{@page_change.max_value}' value='#{@page_change.prior_value}' />"

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
    if url.indexOf(location.protocol + "//" + location.host) == -1
      url = location.protocol + "//" + location.host + url

    $.ajax
      url: url
      dataType: 'json'
      beforeSend: (xhr) =>
        @$content.addClass('ajax_request')

        if @pending_request && break_pending
          if 'abort' in pending_request
            @pending_request.abort()
          else
            @pending_request.aborted = true
          @pending_request = null

        if @pending_request # $(@).hasClass("disabled")
          return xhr.abort()

        cached_data = AjaxCacher.get(url)

        if cached_data
          xhr.abort()

          if 'abort' of cached_data && 'setRequestHeader' of cached_data
            #cached_data
              #.success(xhr.success)
              #.complete(xhr.complete)
              #.error(xhr.error)
          else
            @_process_ajax_content cached_data, url
            @pending_request = null
            @$content.removeClass('ajax_request')

        else
          pending_request = xhr

        # если подгрузка следующей страницы при прокруте, то никаких индикаций загрузки не надо
        #return if $postloader
        #if $(".ajax").children().length isnt 1 or $(".ajax").children(".ajax-loading").length isnt 1
          #$(".ajax:not(.no-animation), .ajax-opacity").animate opacity: 0.3
          #$(".ajax.no-animation").css opacity: 0.3
        #$.cursorMessage()

      success: (data, status, xhr) =>
        AjaxCacher.push url, data
        return if 'aborted' of xhr && xhr.aborted
        @_process_ajax_content data, url

      complete: (xhr) =>
        @pending_request = null
        @$content.removeClass('ajax_request')

      error: (xhr, status, error) =>
        if xhr?.responseText?.includes('age-restricted-warning')
          Turbolinks.visit location.href
        else
          $.flash alert: "Пожалуста, повторите попытку позже"

  #process_ajax = (data, url, $postloader) ->
    #(if $postloader then process_ajax_postload(data, url, $postloader) else process_ajax_response(data, url))

  # обработка контента, полученного от аякс-запроса
  _process_ajax_content: (data, url) ->
    # отслеживание страниц в гугл аналитике и яндекс метрике
    if '_gaq' of window
      _gaq.push [
        '_trackPageview'
        url
      ]
    if 'yaCounter7915231' of window
      yaCounter7915231.hit url

    document.title = "#{data.title}"

    @$content
      .html(data.content)
      .process()

    $('.head h1').html data.title
    $('.head .notice').html data.notice

    @$link_current.html data.current_page
    @$link_total.html data.total_pages

    @$link_prev.attr(href: data.prev_page || '', action: data.prev_page)
    if data.prev_page
      @$link_prev.removeClass "disabled"
    else
      @$link_prev.addClass "disabled"

    @$link_next.attr(href: data.next_page || '', action: data.next_page)
    if data.next_page
      @$link_next.removeClass "disabled"
    else
      @$link_next.addClass "disabled"

    @$pagination.toggle !(@$link_next.hasClass('disabled') && @$link_prev.hasClass('disabled'))
