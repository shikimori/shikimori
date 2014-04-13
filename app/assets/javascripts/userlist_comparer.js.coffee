# обработчики для списка
apply_list_handlers = ->
  $(".b-table tr.selectable").tooltip $.extend($.extend({}, tooltip_options),
    offset: [
      3
      -520
    ]
    position: "bottom right"
    opacity: 1
    onBeforeShow: null
    onBeforeHide: null
    moved: true
  )

$ ->
  load_page = ->
    url = location.href
    params.parse url if url != params.last_compiled
    do_ajax.call @, url

  type = if $(".anime-params-controls").length > 0
    "anime"
  else
    "manga"

  params = new AniMangaParamsParser location.pathname.replace(/(\/vs\/[^\/]*)\/.*/, "$1"), (data) ->
    History.pushState null, null, data

  History.Adapter.bind window, 'statechange', load_page
  apply_list_handlers()
  $('.ajax').on 'ajax:success', apply_list_handlers
