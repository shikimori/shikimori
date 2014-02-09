object nil

node :content do
  render_to_string(partial: 'abuse_request', collection: @processed, formats: :html, layout: false) +
    (@add_postloader ?
      render_to_string(partial: 'site/postloader', locals: { url: page_abuse_requests_url(page: @page+1, format: :json) }, formats: :html, layout: false) :
      '')
end
