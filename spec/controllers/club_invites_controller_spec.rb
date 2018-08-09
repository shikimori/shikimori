describe ClubInvitesController do
  include_context :authenticated, :user

  describe '#create' do
    let!(:member_role) { create :club_role, club: club, user: user }
    let(:user_2) { create :user, :user }
    before { post :create, params: { club_id: club.id, club_invite: { club_id: club.id, src_id: user.id, dst_id: user_2.nickname } } }

    it { expect(response).to have_http_status :success }
  end

  describe '#accept' do
    let(:club_invite) { create :club_invite, :pending, dst: user, club: club }
    before { post :accept, params: { club_id: club_invite.club_id, id: club_invite.id } }

    it do
      expect(resource).to be_closed
      expect(club.reload.member? user).to eq true
      expect(response).to have_http_status :success
    end
  end

  describe '#reject' do
    let(:club_invite) { create :club_invite, :pending, dst: user, club: club }
    before { post :reject, params: { club_id: club_invite.club_id, id: club_invite.id } }

    it do
      expect(resource).to be_closed
      expect(club.reload.member? user).to eq false
      expect(response).to have_http_status :success
    end
  end
end
