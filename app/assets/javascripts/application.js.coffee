# require anime_online/application
# require manga_online/application

$ =>
  $body = $(document.body)
  @ENV = $body.data 'env'
  @USER_ID = $body.data 'user_id'
  @USER_SIGNED_IN = !!@USER_ID
  @DAY_REGISTERED = $body.data 'day_registered'
  @WEEK_REGISTERED = $body.data 'week_registered'
  @IGNORE_COPYRIGHT = $body.data 'ignore_copyright'
  @LOCALE = $body.data 'locale'

  @IGNORED_TOPICS = $body.data 'ignored_topics'

  @OPTIONS =
    comments_auto_collapsed: $body.data('comments_auto_collapsed')
    comments_auto_loaded: $body.data('comments_auto_loaded')

  moment.locale(LOCALE)
  @MOMENT_DIFF = moment($body.data('server_time')).diff(new Date())

  $(document).trigger 'page:load', true

  if USER_SIGNED_IN && !window.faye_loader
    @faye_loader = new FayeLoader()
    @comments_notifier = new CommentsNotifier()

  $('.appear-marker').appear()

  $.form_navigate
    size: 250
    message: "Вы написали и не сохранили какой-то комментарий! Уверены, что хотите покинуть страницу?"

  if match = location.hash.match(/^#(comment-\d+)$/)
    $("a[name=#{match[1]}]").closest('.b-comment').yellowFade()

  # отдельный эвент для ресайзов и скрола
  $(window).on 'resize', $.debounce(500, -> $(document.body).trigger 'resize:debounced')
  $(window).on 'scroll', $.throttle(750, -> $(document.body).trigger 'scroll:throttled')

$(document).on 'page:restore', (e, is_dom_content_loaded) ->
  $(document.body).process()

$(document).on 'page:load', (e, is_dom_content_loaded) =>
  if @is_mobile()
    Turbolinks.enableProgressBar false
    Turbolinks.enableProgressBar true,  '.turbolinks'
  else
    Turbolinks.enableProgressBar true

  #unless is_dom_content_loaded
    #turbolinks_compatibility()

  # отображение flash сообщений от рельс
  $('p.flash-notice').each (k, v) ->
    $.flash notice: v.innerHTML if v.innerHTML.length

  $('p.flash-alert').each (k, v) ->
    $.flash alert: v.innerHTML if v.innerHTML.length

  #$(document.body).addClass 'l-mobile' if is_mobile()
  $(document.body).process()

  # переключатели видов отображения списка
  $('.b-list_switchers .switcher').on 'click', ->
    $.cookie $(@).data('name'), $(@).data('value'), expires: 730, path: "/"
    Turbolinks.visit location.href

#$(document).on 'page:fetch', ->
  #$('.l-page').css opacity: 0.3

#$(document).on 'page:restore', ->
  #turbolinks_compatibility()
  #$('.l-page').css opacity: 1

# для совместимости с турболинками
#turbolinks_compatibility = ->
  #$('#fancybox-wrap').remove()
  #$.fancybox.init()
