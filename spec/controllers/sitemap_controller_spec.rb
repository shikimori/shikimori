describe SitemapController do
  before { get :index }
  it { expect(response).to have_http_status :success }
end
