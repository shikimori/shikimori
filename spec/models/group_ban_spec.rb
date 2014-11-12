describe GroupBan, :type => :model do
  context 'relations' do
    it { should belong_to :group }
    it { should belong_to :user }
  end

  context 'validations' do
    it { should validate_presence_of :group }
    it { should validate_presence_of :user }
  end

  describe 'callbacks' do
    let(:user) { create :user }
    let(:group) { create :group }

    context 'member' do
      let!(:group_role) { create :group_role, user: user, group: group }
      let!(:outgoing_invite) { create :group_invite, src: user, group: group, dst_id: group.owner_id }
      before { create :group_ban, group: group, user: user }

      it { expect(group.reload.joined? user).to be false }
      it { expect(group.invites).to be_empty }
    end

    context 'not a member' do
      let!(:incoming_invite) { create :group_invite, dst: user, group: group, src_id: group.owner_id }
      before { create :group_ban, group: group, user: user }
      it { expect(group.invites).to be_empty }
    end
  end
end
