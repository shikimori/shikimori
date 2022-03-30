json.content render(
  partial: 'moderations/news/news',
  collection: @processed,
  formats: :html
)

if @processed.size == controller.class::PROCESSED_PER_PAGE
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
