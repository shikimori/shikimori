json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'animes/reviews/group',
    locals: {
      collection: @collection,
      resource: @resource,
      is_preview: @is_preview
    },
    formats: :html
  )
)

if !@is_preview && @collection&.next_page?
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      filter: 'b-review',
      next_url: current_url(page: @collection.next_page),
      prev_url: (
        current_url(page: @collection.prev_page) if @collection.prev_page?
      ),
      pages_limit: controller.class::PER_PAGE
    },
    formats: :html
  )
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
