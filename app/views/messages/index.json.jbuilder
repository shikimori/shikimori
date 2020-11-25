json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'messages/message',
    collection: @collection,
    locals: { reply_as_link: @messages_type == :private },
    formats: %i[html]
  )
)

if @add_postloader
  json.postloader render(
    'blocks/postloader',
    filter: 'b-message',
    next_url: index_profile_messages_url(@resource, messages_type: @messages_type, page: @page + 1)
  )
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
