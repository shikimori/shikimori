import delay from 'delay'
import Turbolinks from 'turbolinks'
import { debounce } from 'throttle-debounce'
import ShikiHtml5Video from 'views/application/shiki_html5_video'

page_load 'anime_videos_index', ->
  init_video_player()

  debounced_resize = debounce(250, resize_video_player)
  debounced_resize()

  $(window).on 'resize', debounced_resize
  $(window).one 'page:before-unload', ->
    $(window).off 'resize', debounced_resize

  # переключение вариантов видео
  $('.video-variant-switcher').on 'click', switch_video_variant

  # select current video kind
  $player = $('.b-video_player')
  kind = $player.data 'kind'
  $switcher = $(".video-variant-switcher[data-kind='#{kind}']")
  if kind && $switcher.length
    $switcher.click()
  else
    $('.video-variant-switcher').first().click()

  # выбор видео
  $('.l-page').on 'ajax:before', '.b-video_variant a', ->
    $('.player-container').addClass 'b-ajax'

  $('.l-page').on 'ajax:success', '.b-video_variant a', (e, html) ->
    $('.player-container')
      .removeClass('b-ajax')
      .html(html)
    init_video_player()

    if Modernizr.history
      window.history.pushState(
        { turbolinks: true, url: e.target.href },
        '',
        e.target.href
      )

init_video_player = ->
  resize_video_player()

  $player = $('.b-video_player')
  # html 5 video player
  $video = $player.find('video')
  new ShikiHtml5Video $video if $video.length

  # some logic
  # highlight current episode
  $player = $('.b-video_player')
  episode = $player.data 'episode'
  $(".c-anime_video_episodes .b-video_variant[data-episode='#{episode}']")
    .addClass('active')
      .siblings()
      .removeClass('active')

  # highlight current video by id
  $(".b-video_variant.special[data-video_id='#{$player.data('video_id')}']")
    .addClass('active')
      .siblings()
      .removeClass('active')

  $player.data('video_ids')?.forEach (video_id) ->
    $(".b-video_variant:not(.special)[data-video_id='#{video_id}']")
      .addClass('active')
        .siblings()
        .removeClass('active')

  # инкремент числа просмотров
  video_url = location.href
  if $player.data('watch-delay')
    delay($player.data('watch-delay')).then ->
      if video_url == location.href
        $.post $player.data('watch-url')

  # handlers
  # показ дополнительных кнопок для видео
  $('.cc-player_controls .show-options').on 'click', toggle_options

  # добавление в список
  $('.cc-player_controls').on 'ajax:success', '.create-user_rate', ->
    # без delay срабатывает ещё increment-user_rate handler
    delay().then =>
      $link = $(@)

      $.notice 'Аниме добавлено в список'
      $link
        .removeClass('create-user_rate')
        .addClass('increment-user_rate')
        .attr
          href: $link.data('increment_url')

      $link
        .find('.label')
        .text $link.data('increment_text')

  # отметка о прочтении
  $('.cc-player_controls').on 'ajax:before', '.increment-user_rate', ->
    $(@).addClass 'b-ajax'

  $('.cc-player_controls').on 'ajax:complete', '.increment-user_rate', ->
    unless $('.increment-user_rate').hasClass('watched')
      $.notice 'Эпизод отмечен просмотренным'

    delay(500).then =>
      $(@).removeClass 'b-ajax'
      Turbolinks.visit $(@).data('next_url')

  # переключение номера эпизода
  $('.cc-player_controls .episode-num input')
    .on 'change', ->
      Turbolinks.visit $(@).data('href').replace('EPISODE_NUMBER', @value)

    .on 'keydown', (e) ->
      if e.keyCode is 10 || e.keyCode is 13
        $(@).trigger 'change'

  # кнопка жалобы
  $('.cc-player_controls .report').on 'click', ->
    if $(@).hasClass 'selected'
      hide_report()
    else
      show_report()

  # отмена жалобы
  $('.cc-anime_video_report-new .cancel').on 'click', hide_report

  # сабмит жалобы
  $('.cc-anime_video_report-new form').on 'ajax:success', ->
    $.notice(
      'Жалоба успешно отправлена и вскоре будет рассмотрена модератором. ' +
        'Домо аригато'
    )
    hide_report()

  $('.about-ads .close', $player).on 'click', (e) ->
    $block = $('.about-ads', $player)
    $.cookie($(e.currentTarget).data('cookie-name'), '1', expires: 60)
    $block.addClass 'removing'
    delay(1000).then -> $block.remove()

show_report = ->
  # $('.cc-player_controls .report').addClass 'selected'
  # $('.cc-options').hide()
  $('.cc-player_controls').hide()
  $('.cc-anime_video_report-new').show()

hide_report = ->
  # $('.cc-player_controls .report').removeClass 'selected'
  # $('.cc-options').show()
  $('.cc-player_controls').show()
  $('.cc-anime_video_report-new').hide()
  toggle_options

toggle_options = ->
  $('.cc-player_controls .show-options').toggleClass 'selected'
  $('.cc-navigation').toggle()
  $('.cc-optional_controls').toggle()

resize_video_player = ->
  $player = $('iframe,object,embed,.player-placeholder', '.player-area')
  max_height = parseInt($(window).height() * 0.95)
  desired_height = parseInt($player.width() * 9 / 16)

  if desired_height > max_height
    $player.height(max_height)
    $player.width(max_height / 9 * 16)
  else
    $player.height(desired_height)

switch_video_variant = (e) ->
  kind = $(e.target).data('kind')

  $('.video-variant-switcher').removeClass 'active'
  $(e.target).addClass 'active'

  $('.video-variant-group').removeClass 'active'
  $(".video-variant-group[data-kind='#{kind}']").addClass 'active'
