bowser = require 'bowser'

require_helpers = require.context('../helpers', true)
require_helpers.keys().forEach(require_helpers)

# require_templates = require.context('../templates', true)
# require_templates.keys().forEach(require_templates)

require_dynamic_elements = require.context('../dynamic_elements', true)
require_dynamic_elements.keys().forEach(require_dynamic_elements)

require_services = require.context('../services', true)
require_services.keys().forEach(require_services)

require_jquery_plugins = require.context('../jquery.plugins', true)
require_jquery_plugins.keys().forEach(require_jquery_plugins)

# require_lib = require.context('../lib', true)
# require_lib.keys().forEach(require_lib)

require_views = require.context('../views', true)
require_views.keys().forEach(require_views)

ShikiUser = require 'models/shiki_user'

#= require_tree ./templates
#= require_tree ./services

#= require ./views/application/view
#= require ./views/application/shiki_view
#= require ./views/application/shiki_editable
#= require_tree ./views

#= require_tree ./models
#= require_tree ./lib
#= require_tree ./blocks

#= require turbolinks

#= require_tree ./pages

$ =>
  window.JS_EXPORTS ||= {}

  $body = $(document.body)
  window.ENV = $body.data 'env'
  window.SHIKI_USER = new ShikiUser($body.data('user'))
  window.LOCALE = $body.data 'locale'

  if 'atatus' of window
    atatus
      .config(
        '5b46674439704888913f2a4c47addca7',
        { customData: { SHIKI_USER: SHIKI_USER.id } }
      ).install?()

  I18n.locale = LOCALE
  moment.locale LOCALE

  window.MOMENT_DIFF = moment($body.data('server_time')).diff(new Date())

  $(document).trigger 'page:load', true

  if SHIKI_USER.is_signed_in && !window.SHIKI_FAYE_LOADER
    window.SHIKI_FAYE_LOADER = new FayeLoader()
    window.SHIKI_COMMENTS_NOTIFIER = new CommentsNotifier()

  $('.b-appear_marker.active').appear()

  $.form_navigate
    size: 250
    message: I18n.t('frontend.application.sure_to_leave_page')

  if match = location.hash.match(/^#(comment-\d+)$/)
    $("a[name=#{match[1]}]").closest('.b-comment').yellow_fade()

  # отдельный эвент для ресайзов и скрола
  $(window).on 'resize', $.debounce(500, -> $(document.body).trigger 'resize:debounced')
  $(window).on 'scroll', $.throttle(750, -> $(document.body).trigger 'scroll:throttled')

$(document).on 'page:restore', (e, is_dom_content_loaded) ->
  $(document.body).process()

$(document).on 'page:load', (e, is_dom_content_loaded) =>
  if is_mobile()
    Turbolinks.enableProgressBar false
    Turbolinks.enableProgressBar true,  '.turbolinks'
  else
    Turbolinks.enableProgressBar true

  document.body.classList.add(
    bowser.name.toLowerCase().replace(/ /g, '_')
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

