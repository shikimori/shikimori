describe Moderations::RolesController do
  include_context :authenticated, :user

  describe '#index' do
    before { get :index }
    it { expect(response).to have_http_status :success }
  end

  describe '#show' do
    before { get :show, id: role }

    context 'invalid role' do
      let(:role) { 'zxc' }
      it { expect(response).to redirect_to moderations_roles_url }
    end

    context 'valid role' do
      let(:role) { 'admin' }
      it do
        expect(collection).to eq user_admin
        expect(response).to have_http_status :success
      end
    end
  end
end
