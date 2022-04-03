json.content render(
  partial: 'versions/version',
  collection: @collection,
  formats: :html
)

if @collection.size == controller.class::VERSIONS_PER_PAGE
  json.postloader render(
    partial: 'blocks/postloader',
    locals: {
      filter: 'b-log_entry',
      next_url: current_url(page: @page + 1),
      prev_url: @page > 1 ? current_url(page: @page - 1) : nil
    },
    formats: :html
  )
end
