describe Moderations::UsersController do
  describe '#index' do
    before { get :index }
    it { expect(response).to have_http_status :success }
  end
end
