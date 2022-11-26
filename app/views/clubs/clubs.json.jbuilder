json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'clubs/club',
    collection: @collection,
    locals: {
      content_by: :detailed
    },
    cached: ->(entry) { cache_keys entry, :detailed },
    formats: :html
  )
)

if @collection.next_page?
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      filter: 'b-club',
      next_url: current_url(page: @collection.next_page),
      prev_url: (current_url(page: @collection.prev_page) if @collection.prev_page?) # rubocop:disable LineLength
    },
    formats: :html
  )
end


json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
