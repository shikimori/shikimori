
describe SitemapController do
  it 'works' do
    FactoryGirl.create :anime, :description => 'test'

    get :index
    response.should be_success
  end
end
