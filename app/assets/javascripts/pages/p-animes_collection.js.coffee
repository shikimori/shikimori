# require social/addthis_widget

$(document).on 'page:restore', ->
  $('.ajax').css opacity: 1

$(document).on 'page:load', ->
  return unless document.body.id == 'animes_collection_index'

  if $('.l-menu .ajax-loading').exists()
    $('.l-menu').one 'ajax:success', init_catalog
  else
    init_catalog()

  new PaginatedCatalog()

init_catalog = ->
  type = if $('.anime-params-controls').exists() then 'anime' else 'manga'
  base_path = "/#{type}s"

  #if location.pathname.match(/recommendations/)
    #base_path = _(location.pathname.split("/")).first(5).join("/")
    #type = "recommendation"

  params = new AnimesParamsParser base_path, location.href, (url) ->
    $('.ajax').css opacity: 0.3
    Turbolinks.visit url, true
    if $('.l-page.menu-expanded').exists()
      $(document).one 'page:change', -> $('.l-page').addClass('menu-expanded')

  ##pending_load load_page

#load_page = ->
  #console.log 'load_page'
  #url = location.href
  #params.parse url  unless url is params.last_compiled
  #do_ajax.call this, url, null, true


#pending_load = (load_page) ->
  #$pending = $("p.pending")
  #if $pending.length
    #AjaxCacher.clear location.href
    #_.delay (->
      #load_page(location.href).success ->
        #pending_load load_page
        #return

      #return
    #), 5000
  #else
    #$(".pending-loaded").show()
