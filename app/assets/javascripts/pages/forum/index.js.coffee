# инициализация раздела
$('.ajax').live 'index:success', ->
  _log 'index:success'

# сокращение высоты топиков
$('.ajax').live 'height:check index:success', ->
  # сокращение высоты топиков
  $('.height-unchecked', @).each ->
    $this = $(@)
    $content = if $this.hasClass('inner-block')
      $this
    else
      $this.find('>.body')

    if $content.height() > 140
      $content.addClass 'shortened'
      $('<div class=\"height-shortener\" title=\"Развернуть\"><div>...</div></div>').insertAfter $content
    $this.removeClass 'height-unchecked'

# при загрузке новой страницы инициация проверки высоты топиков
$(".b-postloader").live "postloader:success", ->
  _.delay ->
    $(".ajax").trigger "height:check"

# раскрытие содержимого топика по клику на сокращалку
$(".height-shortener").live "click", ->
  $this = $(@)
  height = $this.prev().outerHeight() + $this.outerHeight()

  $this.prev().removeClass("shortened")
    .animated_expand(height)

  $this.remove()

# ask deletion
$('.topic-block .content .item-delete').live 'click', ->
  $block = $(@).parents(".topic-block")
  $('.main-controls', $block).hide()
  $('.delete-controls', $block).show()

# cancel deletion
$('.topic-block .content .item-delete-cancel').live 'click', ->
  $block = $(@).parents(".topic-block")
  $('.main-controls', $block).show()
  $('.delete-controls', $block).hide()

# удаление топика
$(".topic-block .content .delete-controls .item-delete-confirm").live "ajax:success", (e, data) ->
  $block = $(@).parents(".topic-block")
  $block.css(minHeight: "0px").animate
    height: "0px"
  , ->
    $block.remove()

# формиррование урла для загрузки комментариев по клику на 'Показать N комментариев'
$(document).on 'ajax:before', '.topic-block .click-loader', (e) ->
  $this = $(@)

  # faye-loader делает совсем другое
  return if $this.hasClass("faye-loader")

  $this.data href: $this.data('href-template').replace('SKIP', $this.data('skip'))

# загрузка комментариев по клику на 'Показать N комментариев'
$(document).on 'ajax:success', '.topic-block .click-loader', (e, data) ->
  $this = $(@)

  # faye-loader делает совсем другое
  return if $this.hasClass("faye-loader")

  # у подгруженных комментариев надо сначала вырезать те, которые уже присутствуют на странице
  $present_comments = $this.closest('.comments').find('.comment-block')
  exclude_selector = _.compact(_.map($present_comments, (v, k) ->
    ".#{match[0]}" if match = v.className.match /comment-\d+/
  )).join(', ')

  $comments = $("<div class=\"comments-placeholder\"></div>").append $(data).not(exclude_selector)

  $container = $this.parents('.comments')
  $container
    .find('.comments-container')
    .prepend($comments)
    .show()

  $comments.animated_expand()

  if $this.data 'infinite'
    limit = $this.data('limit')
    count = $this.data('count') - limit

    if count > 0
      $this.data
        skip: $this.data('skip') + limit
        count: count

      $this.html "Показать #{p(_.min([limit, count]), 'предыдущий', 'предыдущие', 'предыдущие')} #{_.min [limit, count]} #{p(count, 'комментарий', 'комментария', 'комментариев')}" + (
          if count > limit then "<span class=\"expandable-comments-count\"> (из #{count})</span>" else ""
        )
    else
      $this.remove()
  else
    $this.html($this.data 'html').removeClass("click-loader").hide()
    $container.find(".comments-hider").show()

# показ комментариев по клику на 'Показать N комментариев'
$(".topic-block .comments-shower").live "click", ->
  $this = $(@)

  # до тех пор, пока висит click-loader, этот обработчик не нужен
  return if $this.hasClass("click-loader")
  # на этот класс навешен селектор, скрывающий border-top у следующего элементам
  $(@).hide()
      .parents(".comments")
      .find(".comments-placeholder")
      .animated_expand()
        .parents(".comments")
        .find(".comments-hider")
        .show()

# скрытие комментариев по клику на 'Скрыть комментарии'
$(".topic-block .comments-hider").live "click", ->
  $comments = $(@).hide()
      .parents(".comments")
      .find(".comments-placeholder")
      .animated_collapse()
        .parents(".comments")
          .find(".comments-shower")
          .show()

# скрытие пустого редактора по снятию с него фокуса
$(".preview .shiki-editor textarea").live "blur", ->
  $this = $(@)
  return unless $this.val() is ""
  $editor = $this.parents(".shiki-editor")
  $editor.hide()
