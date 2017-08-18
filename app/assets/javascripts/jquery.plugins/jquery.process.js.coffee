TOOLTIP_OPTIONS = require 'helpers/tooltip_options'

UserRatesTracker = require 'services/user_rates/tracker'
TopicsTracker = require 'services/topics/tracker'
CommentsTracker = require 'services/comments/tracker'
PollsTracker = require 'services/polls/tracker'

(($) ->
  $.fn.extend
    process: (JS_EXPORTS) ->
      @each ->
        process_current_dom @, JS_EXPORTS
) jQuery

# обработка элементов страницы (инициализация галерей, шрифтов, ссылок)
# TODO: переписать всю тут имеющееся на dynamic_element
process_current_dom = (root = document.body, JS_EXPORTS = window.JS_EXPORTS) ->
  $root = $(root)

  UserRatesTracker.track JS_EXPORTS, $root
  TopicsTracker.track JS_EXPORTS, $root
  CommentsTracker.track JS_EXPORTS, $root
  PollsTracker.track JS_EXPORTS, $root

  new DynamicElements.Parser $with('.to-process', $root)

  $with('time', $root).livetime()

  # то, что должно превратиться в ссылки
  $with('.linkeable', $root)
    .change_tag('a')
    .removeClass('linkeable')

  $with('.b-video.unprocessed', $root).shiki_video()

  # стена картинок
  $with('.b-shiki_wall.unprocessed', $root)
    .removeClass('unprocessed')
    .each ->
      new Wall.Gallery @

  console.error 'found unprocessed topic!!!!!' if $with('.b-topic.unprocessed', $root).length

  # блоки, загружаемые аяксом
  $with('.postloaded[data-href]', $root).each ->
    $this = $(@)
    return unless $this.is(':visible')
    $this.load $this.data('href'), ->
      $this
        .removeClass('postloaded')
        .process()
        .trigger('postloaded:success')

    $this.attr 'data-href', null

  # чёрные мелкие тултипы
  $with('.b-tooltipped.unprocessed', $root)
    .removeClass('unprocessed')
    .each ->
      return if (is_mobile() || is_tablet()) && !@classList.contains('mobile')

      $tip = $(@)

      gravity = switch $tip.data('direction')
        when 'top' then 's'
        when 'bottom' then 'n'
        when 'right' then 'w'
        else 'e'

      $tip.tipsy
        gravity: gravity
        html: true
        prependTo: document.body

  # подгружаемые тултипы
  $with('.anime-tooltip', $root)
    .tooltip(TOOLTIP_OPTIONS.ANIME_TOOLTIP)
    .removeClass('anime-tooltip')
    .removeAttr('title')

  $with('.bubbled', $root)
    .addClass('bubbled-processed')
    .removeClass('bubbled')
    .tooltip Object.add(TOOLTIP_OPTIONS.COMMON_TOOLTIP,
      offset: [-48, 10, -10]
    )

  $with('.b-spoiler.unprocessed', $root).spoiler()

  $with('img.check-width', $root)
    .removeClass('check-width')
    .normalize_image(append_marker: true)
  $with('.b-image.unprocessed', $root)
    .removeClass('unprocessed')
    .magnific_rel_gallery()

  $with('.b-show_more.unprocessed', $root)
    .removeClass('unprocessed')
    .show_more()

  # сворачиваение всех нужных блоков "свернуть"
  ($.cookie('collapses') || '')
    .replace(/;$/, '')
    .split(';')
    .forEach (v, k) ->
      $with("#collapse-#{v}", $root)
        .filter(':not(.triggered)')
        .trigger('click', true)

  # выравнивание картинок в галерее аниме постеров
  $posters = $with('.align-posters.unprocessed', $root)
  if $posters.length
    $posters.removeClass('unprocessed').find('img').imagesLoaded ->
      $posters.align_posters()

  # блоки модерации
  $with('.b-log_entry.unprocessed', $root)
    .removeClass('unprocessed')
    # вопрос о причине отказа для правки
    .on 'click', '.user_change-deny', (e) ->
      href = $(@).data('href')
      reason = prompt $(@).data('reason-prompt')

      if reason == null
        false
      else
        $(@).attr href: "#{href}?reason=#{reason}"
