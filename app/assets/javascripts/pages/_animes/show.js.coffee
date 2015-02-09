# генерация истории аниме/манги
build_history = ->
  $history_block = $(".menu-right .history")

  # тултипы истории
  $(".person-tooltip", $history_block).tooltip
    position: "top right"
    offset: [
      -28
      -28
    ]
    relative: true
    place_to_left: true

  # подгрузка тултипов истории
  history_load_triggered = false

  $history_block.hover ->
    return  if history_load_triggered
    history_load_triggered = true
    $.getJSON $(@).attr("data-remote"), (data) ->
      for id of data
        $tooltip = $(".tooltip-details", "#history-entry-#{id}-tooltip")
        continue unless $tooltip.length

        if data[id].length
          $tooltip.html _.map(data[id], (v, k) ->
            "<a href=\"#{v.link}\" rel=\"nofollow\">#{v.title}</a>"
          ).join('<br />')
        else
          $("#history-entry-#{id}-tooltip").children().remove()

$ ->
  # anime history block
  build_history()

  # anime history tooltips
  $('.person-tooltip').tooltip
    position: 'top right'
    offset: [-28, -22]
    relative: true
    place_to_left: true

  # slides
  $('.slider-control').click (e) ->
    # we should ignore middle button click
    return if in_new_tab(e)
    href = ($(@).children("a").attr("href") || $(@).children("span.link").data("href"))
    History.pushState null, null, href.replace(/http:\/\/.*?\//, "/")
    false

  $controls = $('.slider-control', '.animanga-right-menu')
  $('.entry-content-slider').makeSliderable
    $controls: $controls
    history: true
    remote_load: true
    easing: "easeInOutBack"
    onslide: ($control) ->
      $controls.removeClass "selected"
      $control.addClass "selected"

  History.Adapter.bind window, "statechange", ->
    url = location.href.replace(/http:\/\/.*?\//, "/")
    $target = undefined
    $(".slider-control a,.slider-control span.link").each (k, v) ->
      href = if @className.indexOf("link") is -1 then @href else $(@).data("href")
      if url.indexOf(href.replace(/http:\/\/.*?(?=\/)/, "")) != -1
        $target = $(@).parent()

    # отдельное правило для редактирования рецензий
    $target = $('.slider-control-reviews-edit') if url.match(/\/reviews\/\d+\/edit/)

    menu_url = ($target.children('a').attr('href') || $target.children('span.link').data('href')).replace(/http:\/\/.*?(?=\/)/, "")
    if menu_url != url
      # в нужном li делается подмена урла, т.к. урл для загрузки страницы будет взят оттуда, а затем после загрузки страницы урл меняется назад
      $target.children().attr(href: url).data(href: url)
      $target.trigger 'slider:click'
      $target.children().attr(href: menu_url).data(href: menu_url)
    else
      $target.trigger 'slider:click'

  $(window).trigger 'statechange'

  # height fix for related anime
  names = $('.entry-block .name')
  max_height = _.max names.map(-> $(@).height())
  $('.entry-block .name p').each ->
    $this = $(@)
    height = $this.height()
    $this.css height: height
    $this.addClass 'f17'  if $this.parent().height() < max_height

  names.height max_height

  $('.anime-rate')
    # клик по добавлению в свой список
    .on 'click', '.add-to-list', ->
      $form = $(@).closest('form')

      $form.find('.user_rate_status input').val $(@).data('status')
      $form.submit()

    # клик по раскрытию вариантов добавления в список
    .on 'click', '.expand-options', ->
      $(@).toggleClass 'selected'

      $options = $('.anime-rate .expanded-options')

      unless $options.data 'height'
        $options
          .data height: $options.height()
          .css(height: 0)
          .show()

      (=>
        if $(@).hasClass 'selected'
          $options.css height: $options.data('height')
          $('.anime-rate .add-to-list:not(.option)').hide()
        else
          $options.css height: 0
          $('.anime-rate .add-to-list:not(.option)').show()
      ).delay()

    # отмена редактирования user_rate
    .on 'click', '.cancel', ->
      $show = $('.anime-rate .rate-show').show()
      $edit = $('.anime-rate .rate-edit').hide()

      $('.anime-rate .rate-container').css
        height: $show.data('height')

    # сабмит формы user_rate
    .on 'ajax:success', '.new_user_rate, .increment, .remove', (e, html) ->
      $('.anime-rate').html html
      $('.anime-rate .scores-user').makeRateble()

    # завершение редактирования user_rate
    .on 'ajax:success', '.edit_user_rate', (e, html) ->
      $('.anime-rate .rate-show').replaceWith($(html).find('.rate-show'))
      $('.anime-rate .rate-show').data height: $('.anime-rate .rate-show').height()
      $('.anime-rate .scores-user').makeRateble()

      $('.anime-rate .cancel').click()

    # клик на изменение user_rate - подгрузка и показ формы
    .on 'ajax:success', '.item-edit', (e, edit_html) ->
      $show = $('.anime-rate .rate-show')
      $show
        .data(height: $show.height())
        .hide()

      $edit = $('.anime-rate .rate-edit')
      $edit
        .html(edit_html)
        .data(height: $edit.height())
        .show()

      $('.anime-rate .rate-container').css height: $show.data('height')
      (-> $('.anime-rate .rate-container').css height: $edit.data('height')).delay()

  # user ratings
  $scores_user = $(".anime-rate .scores-user")
  $scores_user.makeRateble() if $scores_user.is(":visible")

# клик по заголовку аниме
$('.anime-title a').live "click", ->
  $(".slider-control-info a").trigger "click"
  false

# клик по кнопке комментировать
$(".actions .comment").live "click", ->
  editor_selector = ".slide > .info .comments .comments-container > .shiki-editor:first-child"
  if $(".slide > .info").hasClass("selected")
    $(editor_selector).focus()

  else
    $(".slide > .info").one "slide:success", ->
      # дождали завершения работы слайдера, и теперь либо переносим фокус, либо дожидаемся загрузки аякса
      $editor = $(editor_selector)
      if $editor.length
        $editor.focus()
      else
        $(".slide > .info").one "ajax:success", ->
          _.delay ->
            $(editor_selector).focus()

    $(".slider-control-info").trigger "click"
