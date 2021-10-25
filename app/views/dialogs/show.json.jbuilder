json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'messages/message',
    collection: @collection,
    formats: :html
  )
)

if @add_postloader
  json.postloader render(
    'dialogs/postloader',
    next_url: show_profile_dialog_url(@dialog.user, @dialog.target_user.to_param, page: @page + 1)
  )
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
