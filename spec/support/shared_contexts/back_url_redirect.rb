shared_context :back_redirect do
  let(:back_url) { '/where_i_came_from' }
  before { request.env['HTTP_REFERER'] = back_url }
end
