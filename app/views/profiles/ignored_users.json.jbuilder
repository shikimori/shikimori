json.content JsExports::Supervisor.instance.sweep(
  current_user,
  render(
    partial: 'profiles/ignored_user',
    collection: @collection,
    as: :user,
    formats: :html
  )
)

if @collection.size == controller.class::IGNORED_PER_PAGE
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      next_url: current_url(page: @page + 1),
      prev_url: @page > 1 ? current_url(page: @page - 1) : nil
    },
    formats: :html
  )
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
