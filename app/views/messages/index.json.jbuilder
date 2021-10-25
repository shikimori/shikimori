json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'messages/message',
    collection: @collection,
    locals: { reply_as_link: @messages_type == :private },
    formats: :html
  )
)

# @collection can be simple array in `chosen` action
if @collection.respond_to?(:next_page?) && @collection.next_page?
  json.postloader render(
    'blocks/postloader',
    filter: 'b-message',
    next_url: index_profile_messages_url(@resource, messages_type: @messages_type, page: @collection.next_page),
    prev_url: @collection.prev_page? ?
      index_profile_messages_url(@resource, messages_type: @messages_type, page: @collection.prev_page) :
      nil
  )
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
