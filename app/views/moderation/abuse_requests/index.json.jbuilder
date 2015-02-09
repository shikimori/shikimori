json.content render(partial: 'moderation/abuse_requests/abuse_request', collection: @processed, formats: :html)

if @add_postloader
  json.postloader render('blocks/postloader', url: page_moderation_abuse_requests_url(page: @page+1))
end
