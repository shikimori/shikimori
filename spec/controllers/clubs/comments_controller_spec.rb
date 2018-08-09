describe Clubs::CommentsController do
  before { sign_in user }

  let(:club) { create :club }
  let(:user) { create :user }
  let!(:club_role) { create :club_role, role, user: user, club: club }

  describe '#broadcast' do
    subject(:make_request) { get :broadcast, params: { club_id: club.to_param } }

    context 'admin' do
      let(:role) { :admin }
      before { make_request }
      it { expect(response).to have_http_status :success }
    end

    context 'member' do
      let(:role) { :member }
      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end
  end
end
