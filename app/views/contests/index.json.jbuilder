json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'contests/contest',
    collection: @collection,
    formats: :html
  )
)

if @collection.next_page?
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      filter: 'contest',
      next_url: contests_url(page: @collection.next_page),
      prev_url: (contests_url(page: @collection.prev_page) if @collection.prev_page?)
    },
    formats: :html
  )
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
