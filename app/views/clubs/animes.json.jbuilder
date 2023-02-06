json.content JsExports::Supervisor.instance.sweep(
  @is_list ?
    render(
      partial: 'animes/variants/list_item',
      collection: @collection,
      as: :entry,
      formats: :html
    ) :
    render(
      partial: 'animes/anime',
      collection: @collection,
      locals: { cover_notice: :year_kind },
      cached: ->(entry) { cache_keys entry, :relation },
      formats: :html
    )
)

if @collection&.next_page?
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      filter: 'b-catalog_entry',
      next_url: current_url(page: @collection.next_page),
      prev_url: (
        current_url(page: @collection.prev_page) if @collection.prev_page?
      ),
      pages_limit: 10
    },
    formats: :html
  )
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
