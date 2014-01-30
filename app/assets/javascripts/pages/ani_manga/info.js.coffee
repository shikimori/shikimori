$(".slide > .info").live "ajax:success cache:success", (e) ->
  return  if "mutex" of arguments.callee
  arguments.callee.mutex = true
  $this = $(this)

  # редактор описания
  kind = (if $(".entry-content-slider").attr("class").indexOf("manga") is -1 then "anime" else "manga")
  $editor = $(".right-column", $this)
  $editor.on "editor:show", ->
    $(".left-column-wrap", $this).addClass "disabled"

  $editor.on "editor:hide", ->
    $(".left-column-wrap", $this).removeClass "disabled"

  $(".rating.notice").tipsy gravity: "s"
  $(".status-date.notice").tipsy gravity: "s"
  $(".extra .images-list a", $this).fancybox $.galleryOptions
  $(".extra .videos-list.youtube a", $this).fancybox $.youtubeOptions
  $(".extra .videos-list.vk a", $this).fancybox $.vkOptions

  # rating
  $(".scores", $this).makeRateble round_values: false


# похожие аниме, подгружаемые для гостей аяксом
$(".related-entries-loader").live "ajax:success", ->
  $this = $(this)
  $this.removeClass "related-entries-loader"
  process_current_dom $this


# клик по загрузке других названий
$(".other-names.click-loader").live "ajax:success", (e, data) ->
  $(this).parents("p").replaceWith data


# клик по смотреть онлайн
$(".watch-online a").live 'click', ->
  episode = parseInt($(".user-rate-block input[name='rate[episodes]']").val())
  total_episodes = parseInt($(".user-rate-block .total-episodes").html()) || 9999
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
  $(".options-floated .link-comments").trigger "click"

$(".additional-links .link-comment-reviews").live "click", (e) ->
  $.scrollTo ".entry-comments"
  $(".options-floated .link-comment-reviews").trigger "click"
