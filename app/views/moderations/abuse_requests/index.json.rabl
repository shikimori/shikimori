object nil

node :content do
  render_to_string(partial: 'moderations/abuse_requests/abuse_request', collection: @processed, formats: :html, layout: false) +
    (@add_postloader ?
      render_to_string(partial: 'blocks/postloader', locals: { url: page_moderations_abuse_requests_url(page: @page+1) }) :
      '')
end
