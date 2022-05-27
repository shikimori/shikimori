json.content render(
  partial: 'moderations/abuse_requests/abuse_request',
  collection: @processed,
  cached: true,
  formats: :html
)

if @processed.size == controller.class::PER_PAGE
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
