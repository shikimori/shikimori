json.content JsExports::Supervisor.instance.sweep(render(
  partial: 'topics/topic',
  collection: @collection_views,
  as: :topic_view,
  cache: true
))

if @collection.next_page?
  json.postloader render(
    'blocks/postloader',
    filter: 'b-collection-topic',
    next_url: collections_url(page: @collection.next_page, search: params[:search]),
    prev_url: (collections_url(page: @collection.prev_page, search: params[:search]) if @collection.prev_page?)
  )
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
