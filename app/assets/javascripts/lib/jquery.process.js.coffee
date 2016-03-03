(($) ->
  $.fn.extend
    process: ->
      @each ->
        process_current_dom @
) jQuery

# обработка элементов страницы (инициализация галерей, шрифтов, ссылок)
# TODO: переписать всю тут имеющееся на dynamic_element
@process_current_dom = (root = document.body) ->
  $root = $(root)

  $with('.to-process', $root).dynamic_element()

  $with('time', $root).livetime()

  # то, что должно превратиться в ссылки
  $with('.linkeable', $root)
    .change_tag('a')
    .removeClass('linkeable')

  $with('.b-video.unprocessed', $root).shiki_video()

  # стена картинок
  $with('.b-shiki_wall.unprocessed', $root).shiki_wall()
  $with('.b-forum.unprocessed', $root).shiki_forum()
  $with('.b-topic.unprocessed', $root).shiki_topic()
  $with('.b-comment.unprocessed', $root).shiki_comment()

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
    .tooltip(ANIME_TOOLTIP_OPTIONS)
    .removeClass('anime-tooltip')
    .removeAttr('title')

  $with('.bubbled', $root)
    .addClass('bubbled-processed')
    .removeClass('bubbled')
    .tooltip($.extend(offset: [-48, 10, -10], tooltip_options))

  $with('.b-spoiler.unprocessed', $root).spoiler()

  $with('.b-user_rate.unprocessed', $root).user_rate_button()

  $with('img.check-width', $root)
    .removeClass('check-width')
    .normalize_image(append_marker: true)
  $with('.b-image.unprocessed', $root)
    .removeClass('unprocessed')
    .magnific_rel_gallery()

  # сворачиваение всех нужных блоков "свернуть"
  _.each ($.cookie('collapses') || '').replace(/;$/, '').split(';'), (v, k) ->
    $with("#collapse-#{v}", $root).filter(':not(.triggered)').trigger 'click', true

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

# поиск селектора одновременно с добавлением root, если root удовлетворяет селектору
$with = (selector, $root) ->
  if $root.is(selector)
    $root.find(selector).add($root)
  else
    $root.find(selector)
