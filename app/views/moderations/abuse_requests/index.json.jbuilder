json.content render(
  partial: 'moderations/abuse_requests/abuse_request',
  collection: @processed,
  formats: :html
)
json.postloader render(
  'blocks/postloader',
  next_url: page_moderations_abuse_requests_url(page: @page+1)
) if @add_postloader
