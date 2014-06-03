$ ->
  # аяксовая навигация с историей
  History.Adapter.bind window, 'statechange', ->
    url = location.href
    # подсветка комментария при переходе по ссылке с анкором коммента
    if url.match(/^comment-\d+$/)
      $("a[name=#{url}]").parent().yellowFade()
      return
    do_ajax.call @, url

  # отображалка новых комментариев
  window.comments_notifier = new CommentsNotifier() if IS_LOGGED_IN

# клик по тегу топика загружает нужный раздел
$('.topic-block .tag').live 'click', ->
  History.pushState null, null, $(@).data('href').replace(/http:\/\/.*?\//, '/') if $(@).data('href')

# подсветка нужного раздела при аякс подгрузке
$('.ajax').live 'ajax:success', (e, data) ->
  $cur_sec = $(".section-#{data.section}")
  return if $cur_sec.hasClass('selected')
  $cur_sec.parents().children().removeClass 'selected'
  $cur_sec.addClass 'selected'

# навигация по разделам
$('.forum-nav .control').live 'click', (e) ->
  return if in_new_tab(e)
  $this = $(@)
  $this.parent().children().removeClass 'selected'
  $this.addClass 'selected'
  History.pushState null, null, $this.attr('href').replace(/http:\/\/.*?\//, '/')
  false

# добавление нового коммента
$('.shiki-editor form').live 'comment:added', (e, data) ->
  $this = $(@)
  $comment = $(data.html)
  $replace_point = $(".comment-#{data.id}")
  if $replace_point.length
    $replace_point.replaceWith $comment
  else
    $comment.insertBefore $this.parents('.shiki-editor')
  $comment.yellowFade()
  $comment_body = $this.find('.comment_body')
  $comment_body.val('').trigger('update').trigger 'blur'

  # скрывать редактор надо только для превью
  $this.parents('.shiki-editor').hide() if $this.parents('.preview').length

# редактирование топика
$('.topic-block .content .item-edit').live 'click', (e) ->
  # для обзоров аякс подгрузка только на странице аниме
  if $(@).parents('.review-block').length && !$(@).parents('.reviews-index').length
    $(@).parent().click()
  else
    History.pushState null, null, $(@).data('href').replace(/.*?\/\/.*?(?=\/)/, '')

# добавление в ленту
$('.topic-block .content .item-subscribe').live 'ajax:success', (e, data) ->
  $(@).toggleClass 'selected'
  $(@).data method: data.method

# для Ответить у топика отдельный обработчик. Это для топиков об аниме, когда по клику на топик мы просто переводим фокус на shiki-editor, без подгрузки контента
$('.topic-block .content .item-reply').live 'click', ->
  if $(@).data 'disabled'
    $(@).parents('.topic-block')
        .find('.shiki-editor')
        .last()
        .show()
          .find('textarea')
          .focus()
    false
