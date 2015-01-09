describe GroupInvitesController do
  let(:club) { create :group }
  include_context :authenticated, :user

  describe '#create' do
    let!(:member_role) { create :group_role, group: club, user: user }
    let(:user_2) { create :user, :user }
    before { post :create, club_id: club.id, group_invite: { group_id: club.id, src_id: user.id, dst_id: user_2.nickname } }

    it { should respond_with :success }
  end

  describe '#accept' do
    let(:group_invite) { create :group_invite, :pending, dst: user }
    before { post :accept, club_id: group_invite.group_id, id: group_invite.id }
    it { should respond_with :success }
  end

  describe '#reject' do
    let(:group_invite) { create :group_invite, :pending, dst: user }
    before { post :reject, club_id: group_invite.group_id, id: group_invite.id }
    it { should respond_with :success }
  end
end
