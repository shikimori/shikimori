json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'comments/comment',
    collection: @collection,
    formats: :html
  )
)

if @collection.size == controller.class::COMMENTS_LIMIT
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      filter: 'b-comment',
      next_url: current_url(page: @page + 1),
      prev_url: @page > 1 ? current_url(page: @page - 1) : nil
    },
    formats: :html
  )
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
