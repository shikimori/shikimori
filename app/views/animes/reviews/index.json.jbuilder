json.content render(
  partial: 'reviews/group',
  locals: {
    collection: @collection,
    is_preview: @is_preview
  },
  formats: :html
)

if !@is_preview && @collection&.next_page?
  json.postloader render(
    'blocks/postloader',
    filter: 'b-review',
    next_url: current_url(page: @collection.next_page),
    prev_url: (
      current_url(page: @collection.prev_page) if @collection.prev_page?
    ),
    pages_limit: controller.class::PER_PAGE
  )
end
