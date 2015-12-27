describe TopicIgnoresController do
  include_context :authenticated, :user

  # describe '#create' do
    # let!(:member_role) { create :club_role, club: club, user: user }
    # let(:user_2) { create :user, :user }
    # before { post :create, club_id: club.id, club_invite: { club_id: club.id, src_id: user.id, dst_id: user_2.nickname } }

    # it { expect(response).to have_http_status :success }
  # end

  # describe '#accept' do
    # let(:club_invite) { create :club_invite, :pending, dst: user }
    # before { post :accept, club_id: club_invite.club_id, id: club_invite.id }
    # it { expect(response).to have_http_status :success }
  # end

  # describe '#reject' do
    # let(:club_invite) { create :club_invite, :pending, dst: user }
    # before { post :reject, club_id: club_invite.club_id, id: club_invite.id }
    # it { expect(response).to have_http_status :success }
  # end
end
