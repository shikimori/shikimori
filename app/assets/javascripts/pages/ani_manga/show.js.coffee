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

  #$node.hover(function() {
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
  $(".person-tooltip").tooltip
    position: "top right"
    offset: [-28, -22]
    relative: true
    place_to_left: true

  # slides
  $(".slider-control").click (e) ->
    # we should ignore middle button click
    return if in_new_tab(e)
    History.pushState null, null, ($(@).children("a").attr("href") or $(@).children("span.link").data("href")).replace(/http:\/\/.*?\//, "/")
    false

  $controls = $(".slider-control", $(".animanga-right-menu"))
  $(".entry-content-slider").makeSliderable
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

    # отдельное правило для редактирования описаний
    $target = $(".slider-control-reviews-edit")  if url.match(/\/reviews\/\d+\/edit/)
    menu_url = ($target.children("a").attr("href") or $target.children("span.link").data("href")).replace(/http:\/\/.*?(?=\/)/, "")
    if menu_url != url
      $target.trigger "slider:click"
    else
      # в нужном li делается подмена урла, т.к. урл для загрузки страницы будет взят оттуда, а затем после загрузки страницы урл меняется назад
      $target
        .children()
        .attr(href: url)
        .data(href: url)
      $target.trigger 'slider:click'
      $target
        .children()
        .attr(href: menu_url)
        .data(href: menu_url)

  $(window).trigger "statechange"

  # height fix for related anime
  names = $(".entry-block .name")
  max_height = _.max(names.map(->
    $(@).height()
  ))
  $(".entry-block .name p").each ->
    $this = $(@)
    height = $this.height()
    $this.css "height", height
    $this.addClass "f17"  if $this.parent().height() < max_height

  names.height max_height

  # rate
  #$(".rate-statuses li").click ->
    #$this = $(@)
    #$("#rate_status").attr "value", $this.attr("id").match(/\d+/)[0]  if $this.attr("id").match(/rate-status/)
    #$this.parents("form").submit()

  #$("#rate-episodes,#rate-volumes,#rate-chapters").bind("change blur", (e) ->
    #$this = $(@)
    #return  if parseInt(@value, 10) is parseInt($this.data("counter"), 10)
    #$this.data "counter", parseInt(@value, 10)
    #$this.parents("form").submit()
  #).bind("mousewheel", (e) ->
    #return true  unless $(@).is(":focus")
    #if e.originalEvent.wheelDelta and e.originalEvent.wheelDelta > 0
      #@value = parseInt(@value, 10) + 1
    #else @value = parseInt(@value, 10) - 1  if e.originalEvent.wheelDelta and parseInt(@value, 10) > 1
    #false
  #).bind("keydown", (e, inc) ->
    #if e.keyCode is 38 or inc
      #@value = parseInt(@value, 10) + 1
    #else if e.keyCode is 40 and parseInt(@value, 10) > 1
      #@value = parseInt(@value, 10) - 1
    #else if e.keyCode is 27
      #@value = $(@).data("counter")
      #$(@).trigger "blur"
  #).bind "keypress", (e) ->
    #if e.keyCode is 13
      #$(@).trigger "blur"
      #false

  #$("#rate-block .item-add").bind "click", ->
    #$(@).parent().find("input").trigger("keydown", true).trigger "blur"

  #$("#rate-status-form, #rate-episodes-form, #rate-volumes-form, #rate-chapters-form").bind("ajax:success", (e, data, status, xhr) ->
    #$this = $(@)
    #if $this.attr("id") is "rate-episodes-form" or $this.attr("id") is "rate-volumes-form" or $this.attr("id") is "rate-chapters-form"
      #$("#rate-episodes").attr("value", data.episodes).data "counter", parseInt(data.episodes, 10)
      #$("#rate-volumes").attr("value", data.volumes).data "counter", parseInt(data.volumes, 10)
      #$("#rate-chapters").attr("value", data.chapters).data "counter", parseInt(data.chapters, 10)
      #$("#rate-status-" + data.status).trigger "status:select"
    #else
      #$("#rate-status-" + data.status).trigger "status:select"
      #$("#rate-episodes").attr("value", data.episodes).data "counter", parseInt(data.episodes, 10)
      #$("#rate-volumes").attr("value", data.volumes).data "counter", parseInt(data.volumes, 10)
      #$("#rate-chapters").attr("value", data.chapters).data "counter", parseInt(data.chapters, 10)
  #).bind "ajax:failure", ->
    #$(".add-to-list", @).removeClass "active"

  ## добавление в список
  #$("#rate-add").bind "ajax:success", (e, data, status, xhr) ->
    #$this = $(@)

    ## дефолтные значения
    #$("#rate-status-" + data.status).trigger "status:select"
    #$("#rate-episodes").attr("value", data.episodes).data "counter", parseInt(data.episodes, 10)
    #$("#rate-volumes").attr("value", data.volumes).data "counter", parseInt(data.volumes, 10)
    #$("#rate-chapters").attr("value", data.chapters).data "counter", parseInt(data.chapters, 10)
    #$("#rate-rate").html data.rate_content
    #$(".animanga-right-menu .scores-user").data("rateable-initialized", false).makeRateble()

    ## скрыть себя, показать другую кнопку и показать блок статуса
    #$this.parents("li").hide()
    #$("#rate-del").parents("li").show()
    #$("#rate-block").show().yellowFade true

  ## удаление из списка
  #$("#rate-del").bind "ajax:success", (e, data, status, xhr) ->
    #$this = $(@)

    ## скрыть себя, показать другую кнопку и скрыть блок статуса
    #$this.parents("li").hide()
    #$("#rate-add").parents("li").show()
    #$("#rate-block").hide()

  #$(".rate-statuses li").bind "status:select", ->
    #$(@).addClass("selected").siblings().removeClass "selected"

  ## user ratings
  #$scores_user = $(".animanga-right-menu .scores-user")
  #$(".animanga-right-menu .scores-user").makeRateble() if $scores_user.is(":visible")

# высота правого меню
#$('.menu-right').height($('.menu-right-inner').height());

# клик по заголовку аниме
$(".anime-title a").live "click", ->
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
