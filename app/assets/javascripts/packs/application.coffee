require('../vendor/sugar').extend()
require('es6-promise').polyfill()

window.$ = window.jQuery = require 'jquery'

require_vendor = require.context('../vendor', true)
require_vendor.keys().forEach(require_vendor)

require 'magnific-popup'
require 'magnific-popup/dist/magnific-popup.css'
require 'nouislider/distribute/nouislider.css'
require 'pikaday/scss/pikaday.scss'

require 'imagesloaded'

bowser = require 'bowser'

require '../i18n/translations'

window.I18n = I18n
window.z = require('axios')
window.axios = require('axios').create
  headers:
    'X-Requested-With': 'XMLHttpRequest'

window.View = require 'views/application/view'
window.ShikiView = require 'views/application/shiki_view'
window.ShikiEditable = require 'views/application/shiki_editable'
window.ShikiUser = require 'models/shiki_user'

require_helpers = require.context('../helpers', true)
require_helpers.keys().forEach(require_helpers)

require_templates = require.context('../templates', true)
window.JST = require_templates.keys().reduce(
  (memo, module) ->
    memo[module.replace(/^\.\/|\.\w+$/g, '')] = require_templates module
    memo
  , {}
)

require_dynamic_elements = require.context('../dynamic_elements', true)
require_dynamic_elements.keys().forEach(require_dynamic_elements)

require_jquery_plugins = require.context('../jquery.plugins', true)
require_jquery_plugins.keys().forEach(require_jquery_plugins)

# require_views = require.context('../views', true, /^\.\/(?!collections)/)
require_views = require.context('../views', true)
require_views.keys().forEach(require_views)

require_pages = require.context('../pages', true)
require_pages.keys().forEach(require_pages)

require_pages = require.context('../anime_online/pages', true)
require_pages.keys().forEach(require_pages)

require_blocks = require.context('../blocks', true)
require_blocks.keys().forEach(require_blocks)

MobileDetect = require 'mobile-detect'
window.mobile_detect = new MobileDetect(window.navigator.userAgent)

FayeLoader = require '../services/faye_loader'
CommentsNotifier = require '../services/comments_notifier'

bindings = require('helpers/bindings')

$(document).on Object.keys(bindings).join(' '), (e) ->
  for group in bindings[e.type]
    body_classes = if group.conditions.length && group.conditions[0][0] == '.'
      group.conditions
        .filter (v) -> v[0] == '.'
        .map (v) -> "p-#{v.slice 1} "
    else
      null

    if !group.conditions.length
      group.callback()
    else if body_classes && body_classes.length && body_classes.some((v) -> document.body.className.indexOf(v) != -1)
      group.callback()
    else if group.conditions.some((v) -> document.body.id == v)
      group.callback()

$ =>
  window.JS_EXPORTS ||= {}

  $body = $(document.body)
  window.ENV = $body.data 'env'
  window.SHIKI_USER = new ShikiUser($body.data('user'))
  window.LOCALE = $body.data 'locale'

  if 'atatus' of window
    atatus
      .config(
        'e939107bae3f4735891fd79f9dee7e40',
        { customData: { SHIKI_USER: SHIKI_USER.id } }
      ).install?()

  I18n.locale = LOCALE
  moment.locale LOCALE

  window.MOMENT_DIFF = moment($body.data('server_time')).diff(new Date())

  $(document).trigger 'page:load', true

  if SHIKI_USER.is_signed_in && !window.SHIKI_FAYE_LOADER
    window.SHIKI_COMMENTS_NOTIFIER = new CommentsNotifier()
    # delay to prevent page freeze
    delay(150).then -> window.SHIKI_FAYE_LOADER = new FayeLoader()

  $('.b-appear_marker.active').appear()

  $.form_navigate
    size: 250
    message: I18n.t('frontend.application.sure_to_leave_page')

  if match = location.hash.match(/^#(comment-\d+)$/)
    $("a[name=#{match[1]}]").closest('.b-comment').yellow_fade()

  # отдельный эвент для ресайзов и скрола
  $(window).on 'resize', debounce(500, -> $(document.body).trigger 'resize:debounced')
  $(window).on 'scroll', throttle(750, -> $(document.body).trigger 'scroll:throttled')

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

  # отображение flash сообщений от рельс
  $('p.flash-notice').each (k, v) ->
    $.flash notice: v.innerHTML if v.innerHTML.length

  $('p.flash-alert').each (k, v) ->
    $.flash alert: v.innerHTML if v.innerHTML.length

  $(document.body).process()

  # переключатели видов отображения списка
  $('.b-list_switchers .switcher').on 'click', ->
    $.cookie $(@).data('name'), $(@).data('value'), expires: 730, path: "/"
    Turbolinks.visit location.href
