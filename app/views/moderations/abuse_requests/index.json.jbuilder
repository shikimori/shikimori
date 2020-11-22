json.content render(
  partial: 'moderations/abuse_requests/abuse_request',
  collection: @processed,
  formats: :html
)

if @processed.size == controller.class::LIMIT
  json.postloader render(
    'blocks/postloader',
    filter: 'b-log_entry',
    next_url: current_url(page: @page + 1),
    prev_url: @page > 1 ? current_url(page: @page - 1) : nil
  )
end
