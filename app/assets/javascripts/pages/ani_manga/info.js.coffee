#$(".info").live "ajax:success cache:success", (e) ->
$ ->
  return  if "mutex" of arguments.callee
  arguments.callee.mutex = true
  $this = $(this)

  $('.rating.notice').tipsy gravity: 's'
  $('.status-date.notice').tipsy gravity: 's'
  $('.screenshot', $this).fancybox $.galleryOptions
  $('.b-video.youtube a', $this).fancybox $.youtubeOptions
  $('.b-video.vk a', $this).fancybox $.vkOptions

  # rating
  $('.scores', $this).makeRateble round_values: false

# похожие аниме, подгружаемые для гостей аяксом
$('.related-entries-loader').live "ajax:success", ->
  $this = $(this)
  $this.removeClass "related-entries-loader"
  process_current_dom $this

# клик по загрузке других названий
$(".other-names.click-loader").live "ajax:success", (e, data) ->
  $(this).parents("p").replaceWith data

# клик по смотреть онлайн
$(".watch-online a").live 'click', ->
  episode = parseInt($(".menu-rate-block .current-episodes").html())
  total_episodes = parseInt($(".menu-rate-block .total-episodes").html()) || 9999
  watch_episode = if !episode || episode == total_episodes then 1 else episode + 1

  $(@).attr href: $(@).attr('href').replace(/\d+$/, watch_episode)

# раскрытие свёрнутого блока связанного
$(".related-shower").live "click", ->
  $this = $(this)
  $this.addClass("selected").data "disabled", true
  $this.siblings("span").removeClass("selected").data "disabled", false
  $(this).hide().next().show()


# переключение типа комментариев
$(".entry-comments .link").live("ajax:before", (e) ->
  $this = $(this)
  $this.addClass("selected").data "disabled", true
  $this.siblings("span").removeClass("selected").data "disabled", false
  $this.parents(".entry-comments").find(".comments-container").animate opacity: 0.3
).live "ajax:success", (e, data) ->
  $container = $(this).parents(".entry-comments").find(".comments-container").animate(opacity: 1)
  $container.children(":not(.shiki-editor)").remove()
  $container.append data.content


# дополнительные ссылки под текстом аниме
$(".additional-links .link-reviews").live "click", (e) ->
  $(".slider-control-reviews").trigger "click"

$(".additional-links .link-comments").live "click", (e) ->
  $.scrollTo ".entry-comments"
  $(".b-options-floated .link-comments").trigger "click"

$(".additional-links .link-comment-reviews").live "click", (e) ->
  $.scrollTo ".entry-comments"
  $(".b-options-floated .link-comment-reviews").trigger "click"
