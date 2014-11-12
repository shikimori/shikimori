require 'cancan/matchers'

describe GroupInvite, :type => :model do
  context 'relations' do
    it { should belong_to :group }
    it { should belong_to :src }
    it { should belong_to :dst }
    it { should belong_to(:message).dependent(:destroy) }
  end

  context 'validations' do
    it { should validate_presence_of :src }
    it { should validate_presence_of :dst }
    it { should validate_presence_of :group }

    let(:group) { create :group, owner: user }
    let(:user) { create :user }
    let(:group_invite) { build :group_invite, src: user, dst: user, group: group }

    describe 'cannot_be_banned' do
      let!(:ban) { create :group_ban, group: group, user: user }
      before { group_invite.save }
      it { expect(group_invite.errors.messages[:base]).to eq [I18n.t('activerecord.errors.models.group_invite.attributes.base.banned')] }
    end

    describe 'cannot_be_invited' do
      let!(:invite) { create :group_invite, src: user, dst: user, group_id: group.id }
      before { group_invite.save }
      it { expect(group_invite.errors.messages[:base]).to eq [I18n.t('activerecord.errors.models.group_invite.attributes.base.invited')] }
    end

    describe 'cannot_be_joined' do
      let!(:join) { create :group_role, user: user, group: group }
      before { group_invite.save }
      it { expect(group_invite.errors.messages[:base]).to eq [I18n.t('activerecord.errors.models.group_invite.attributes.base.joined')] }
    end
  end

  context 'hooks' do
    let(:group) { create :group }
    let(:src) { create :user }
    let(:dst) { create :user }

    it 'creates GroupRequet message' do
      invite = nil
      expect {
        expect {
          invite = GroupInvite.create src: src, dst: dst, group: group
        }.to change(GroupInvite, :count).by 1
      }.to change(Message, :count).by 1

      message = Message.last
      expect(message.from_id).to eq src.id
      expect(message.to_id).to eq dst.id
      expect(message.subject).to eq invite.id
      expect(message.kind).to eq MessageType::GroupRequest
    end

    it 'destroys its message' do
      invite = nil
      expect {
        expect {
          invite = GroupInvite.create src: src, dst: dst, group: group
        }.to change(Message, :count).by 1
        invite.destroy
      }.to change(Message, :count).by 0
    end

    it 'destroys previous rejected invites' do
      GroupInvite.create src: src, dst: dst, group: group, status: GroupInviteStatus::Rejected
      expect {
        GroupInvite.create src: src, dst: dst, group: group, status: GroupInviteStatus::Pending
      }.to change(GroupInvite, :count).by 0
    end
  end

  context 'instance_methods' do
    describe '#accept!' do
      subject(:invite) { create :group_invite, :pending }
      before { invite.accept! }

      its(:status) { should eq GroupInviteStatus::Accepted }
      it { expect(invite.group.joined? invite.dst).to be true }
    end

    describe '#reject!' do
      subject(:invite) { create :group_invite, :pending }
      before { invite.reject! }

      its(:status) { should eq GroupInviteStatus::Rejected }
      it { expect(invite.group.joined? invite.dst).to be false }
    end
  end

  describe 'permissions' do
    let(:user) { build_stubbed :user }
    subject { Ability.new user }

    context 'existing_invite' do
      context 'own_invite' do
        let(:group_invite) { build_stubbed :group_invite, dst: user, status: status }

        context 'pending_invite' do
          let(:status) { GroupInviteStatus::Pending }
          it { should be_able_to :accept, group_invite }
          it { should be_able_to :reject, group_invite }
        end

        context 'accepted_invite' do
          let(:status) { GroupInviteStatus::Accepted }
          it { should_not be_able_to :accept, group_invite }
          it { should_not be_able_to :reject, group_invite }
        end

        context 'rejected_invite' do
          let(:status) { GroupInviteStatus::Rejected }
          it { should_not be_able_to :accept, group_invite }
          it { should_not be_able_to :reject, group_invite }
        end
      end

      context 'foreign_invite' do
        let(:group_invite) { build_stubbed :group_invite }

        it { should_not be_able_to :accept, group_invite }
        it { should_not be_able_to :reject, group_invite }
      end
    end

    context 'new_invite' do
      context 'club_member' do
        let(:group) { build_stubbed :group, member_roles: [create(:group_role, user: user)] }

        context 'from_self' do
          let(:group_invite) { build_stubbed :group_invite, src: user, group: group }
          it { should be_able_to :create, group_invite }
        end

        context 'from_another_user' do
          let(:group_invite) { build_stubbed :group_invite }
          it { should_not be_able_to :create, group_invite, group: group }
        end
      end

      context 'not_a_member' do
        let(:group_invite) { build_stubbed :group_invite, src: user }
        it { should_not be_able_to :create, group_invite }
      end
    end
  end
end
