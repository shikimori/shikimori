describe SitemapController do
  before { get :index }
  it { should respond_with :success }
end
