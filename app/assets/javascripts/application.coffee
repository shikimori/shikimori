#= require_tree ./services

#= require ./views/application/view
#= require ./views/application/shiki_view
#= require ./views/application/shiki_editable
#= require_tree ./views

#= require_tree ./models
#= require_tree ./dynamic_elements
#= require_tree ./lib
#= require_tree ./blocks

#= require turbolinks

#= require_tree ./pages

$ =>
  @JS_EXPORTS ||= {}

  $body = $(document.body)
  @ENV = $body.data 'env'
  @SHIKI_USER = new ShikiUser($body.data('user'))
  @USER_SIGNED_IN = !!@SHIKI_USER.id
  @DAY_REGISTERED = $body.data 'day_registered'
  @WEEK_REGISTERED = $body.data 'week_registered'
  @IGNORE_COPYRIGHT = $body.data 'ignore_copyright'
  @LOCALE = $body.data 'locale'

  @OPTIONS =
    comments_auto_collapsed: $body.data('comments_auto_collapsed')
    comments_auto_loaded: $body.data('comments_auto_loaded')

  if 'atatus' of window
    atatus
      .config(
        '5b46674439704888913f2a4c47addca7',
        { customData: { SHIKI_USER: @SHIKI_USER.id } }
      ).install?()

  I18n.locale = LOCALE
  moment.locale(LOCALE)

  @MOMENT_DIFF = moment($body.data('server_time')).diff(new Date())


  $(document).trigger 'page:load', true

  if USER_SIGNED_IN && !window.faye_loader
    @faye_loader = new FayeLoader()
    @comments_notifier = new CommentsNotifier()

  $('.b-appear_marker.active').appear()

  $.form_navigate
    size: 250
    message: t('frontend.application.sure_to_leave_page')

  if match = location.hash.match(/^#(comment-\d+)$/)
    $("a[name=#{match[1]}]").closest('.b-comment').yellow_fade()

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

  document.body.classList.add(
    bowser.name.toLowerCase().replace(' ', '_')
  )

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
