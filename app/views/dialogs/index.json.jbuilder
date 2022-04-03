json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'dialogs/dialog',
    collection: @collection,
    formats: :html
  )
)

if @add_postloader
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      filter: 'b-dialog',
      next_url: index_profile_dialogs_url(@resource, page: @page + 1)
    },
    formats: :html
  )
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
