#= require pages/p-moderation
#= require pages/p-users-index
#= require pages/p-animes
#= require pages/p-animes_collection-index
#= require pages/p-recommendations-index

#= require_directory ./pages/p-db_entries
#= require pages/p-seyu
#= require pages/p-people
#= require pages/p-characters
#= require pages/p-contests
#= require pages/p-clubs
#= require pages/p-dialogs
#= require pages/p-messages
#= require pages/p-userlist_comparer
#= require pages/p-translations
#= require pages/p-achievements
#= require_directory ./pages/p-reviews
#= require_directory ./pages/p-profiles
#= require_directory ./pages/p-user_rates
#= require_directory ./pages/p-topics
#= require pages/p-tests

# require anime_online/application
# require manga_online/application

$ =>
  $body = $(document.body)
  @ENV = $body.data 'env'
  @USER_SIGNED_IN = $body.data 'user-signed-in'
  @DAY_REGISTERED = $body.data 'day-registered'
  @IGNORE_COPYRIGHT = $body.data 'ignore-copyright'
  @LOCALE = $body.data 'locale'

  @OPTIONS =
    comments_auto_collapsed: $body.data('comments-auto-collapsed')
    comments_auto_loaded: $body.data('comments-auto-loaded')

  moment.locale(LOCALE)
  @MOMENT_DIFF = moment($body.data('server-time')).diff(new Date())

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

#$(document).on 'page:fetch', ->
  #$('.l-page').css opacity: 0.3

#$(document).on 'page:restore', ->
  #turbolinks_compatibility()
  #$('.l-page').css opacity: 1

# для совместимости с турболинками
#turbolinks_compatibility = ->
  #$('#fancybox-wrap').remove()
  #$.fancybox.init()
