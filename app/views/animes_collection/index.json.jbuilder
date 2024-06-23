json.title og.headline
json.notice og.notice

json.content JsExports::Supervisor.instance.sweep(
  current_user,
  render(
    partial: 'animes_collection/cached_collection',
    locals: {
      view: @view
    },
    formats: :html
  )
)
json.page @view.page
json.pages_count @view.pages_count

if @view.next_page_url
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      next_url: @view.next_page_url,
      prev_url: @view.prev_page_url
    },
    formats: :html
  )
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
