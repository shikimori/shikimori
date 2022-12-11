describe Moderations::ChangelogsController do
  describe '#index' do
    include_context :authenticated, :admin
    subject! { get :index }

    it { expect(response).to have_http_status :success }
  end
end
