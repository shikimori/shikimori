#$(".info").live "ajax:success cache:success", (e) ->
$ ->
  return  if "mutex" of arguments.callee
  arguments.callee.mutex = true
  $this = $(this)


# похожие аниме, подгружаемые для гостей аяксом
#$('.related-entries-loader').live "ajax:success", ->
  #$this = $(this)
  #$this.removeClass "related-entries-loader"
  #process_current_dom $this


# дополнительные ссылки под текстом аниме
$(".additional-links .link-reviews").live "click", (e) ->
  $(".slider-control-reviews").trigger "click"

$(".additional-links .link-comments").live "click", (e) ->
  $.scrollTo ".entry-comments"
  $(".b-options-floated .link-comments").trigger "click"

$(".additional-links .link-comment-reviews").live "click", (e) ->
  $.scrollTo ".entry-comments"
  $(".b-options-floated .link-comment-reviews").trigger "click"
