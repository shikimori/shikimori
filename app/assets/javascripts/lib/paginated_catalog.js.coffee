class @PaginatedCatalog
  constructor: ->
    @$ajax = $('.ajax')
    @$pagination = $('.pagination')
    @$link_current = @$pagination.find('.link-current')
    @$link_next = @$pagination.find('.link-next')
    @$link_prev = @$pagination.find('.link-prev')
    @$link_first = @$pagination.find('.link-first')
    @$link_last = @$pagination.find('.link-last')
    @$link_total = @$pagination.find('.link-total')
    @$link_title = @$pagination.find('.link-title')

    entries_per_page = @$ajax.data('entries-per-page')
    entries_per_page_default = 12.0
    @pages_limit = 26 * (entries_per_page_default / entries_per_page)

    @page_change = {}

    @$ajax.on 'postloader:success', @page_loaded
    @$pagination.on 'click', '.link', @link_click
    @$pagination.on 'click', '.no-hover', @page_select

  # клик по ссылке пагинации
  link_click: (e) =>
    return if in_new_tab(e)
    $link = $(e.target)

    unless $link.hasClass('disabled')
      $.scrollTo '.head' if $(window).scrollTop() > 400
      @$ajax.css opacity: 0.3
      Turbolinks.visit $link.attr('href'), true
    false

  # загружена следующая страница при скролле
  page_loaded: (e, $content, data) =>
    @$link_current.html @$link_current.html().replace(/-\d+|$/, "-" + data.current_page)
    @$link_title.html "Страницы"
    @$link_total.html data.total_pages

    @$link_first.attr
      href: data.first_page || ""
      action: data.first_page

    @$link_last.attr
      href: data.last_page || ""
      action: data.last_page

    @$link_prev.attr
      href: data.prev_page || ""
      action: data.prev_page

    @$link_next.attr
      href: data.next_page || ""
      action: data.next_page

    @$link_first.toggleClass 'disabled', !data.first_page
    @$link_last.toggleClass 'disabled', !data.last_page
    @$link_prev.toggleClass 'disabled', !data.prev_page
    @$link_next.toggleClass 'disabled', !data.next_page

    # после pages_limit убираем postloader (слишком много контента на странице оказывается и начинает тормозить)
    if @is_pages_limit()
      @$ajax.find('.b-postloader').remove()

  # наступил ли лимит прокрутки страниц?
  is_pages_limit: ->
    pages = @$link_current.first().html().split("-")
    pages.length > 1 && parseInt(pages[1]) - parseInt(pages[0]) >= @pages_limit

  # клик по блоку выбора страницы
  page_select: (e) =>
    $link = $(e.currentTarget).find(".link-current")
    return if $link.has('input').length

    @page_change.prior_value = parseInt @$link_current.html()
    @page_change.max_value = parseInt @$link_total.html()
    $link.html "<input type='number' min='1' max='#{@page_change.max_value}' value='#{@page_change.prior_value}' />"

    @page_change.$input = $link
      .children()
      .focus()
      .on 'blur', => @apply_page false
      .on 'keydown', (e) =>
        if e.keyCode == 38
          e.target.value = parseInt(e.target.value) + 1

        else if e.keyCode == 40 && parseInt(e.target.value) > 1
          e.target.value = parseInt(e.target.value) - 1

        else if e.keyCode == 27
          @apply_page true

      .on 'keypress', (e) =>
        if e.keyCode == 13
          @apply_page false

      .on 'mousewheel', (e) =>
        if e.originalEvent.wheelDelta && e.originalEvent.wheelDelta > 0 && parseInt(e.target.value) < @page_change.max_value
          e.target.value = parseInt(e.target.value) + 1

        else if e.originalEvent.wheelDelta && parseInt(e.target.value) > 1
          e.target.value = parseInt(e.target.value) - 1

        false

  # применения выбора страницы
  apply_page: (rollback) ->
    value = parseInt(@page_change.$input.val()) || 1

    if rollback || value == @page_change.prior_value
      @page_change.$input.parent().html @page_change.prior_value

    else
      $link = @$link_next
        .add(@$link_prev)
        .filter(':not(.disabled)')
        .first()

      $link
        .attr
          href: $link.attr('href').replace(/\/\d+$/, "/#{value}")
        .trigger('click')

      @page_change.$input.parent().html value

    @page_change.$input = null
