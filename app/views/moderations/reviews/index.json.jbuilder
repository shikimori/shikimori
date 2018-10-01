json.content render(
  partial: 'moderations/reviews/review',
  collection: @processed,
  formats: :html
)

if @processed.size == controller.class::PROCESSED_PER_PAGE
  json.postloader render(
    'blocks/postloader',
    filter: 'b-log_entry',
    next_url: current_url(page: @page + 1),
    prev_url: @page > 1 ? current_url(page: @page - 1) : nil
  )
end
