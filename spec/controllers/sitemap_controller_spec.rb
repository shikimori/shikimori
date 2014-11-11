
describe SitemapController, :type => :controller do
  it 'works' do
    FactoryGirl.create :anime, :description => 'test'

    get :index
    expect(response).to be_success
  end
end
