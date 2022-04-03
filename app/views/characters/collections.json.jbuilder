json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'topics/topic',
    collection: @collection,
    as: :topic_view,
    formats: :html,
    cached: true
  )
)

if @collection.next_page?
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      filter: 'b-collection-topic',
      next_url: collections_character_url(@resource, page: @collection.next_page),
      prev_url: (
        collections_character_url(@resource, page: @collection.prev_page) if @collection.prev_page?
      )
    },
    formats: :html
  )
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
