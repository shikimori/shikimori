require 'spec_helper'
require 'cancan/matchers'

describe GroupInvite do
  context :relations do
    it { should belong_to :group }
    it { should belong_to :src }
    it { should belong_to :dst }
    it { should belong_to(:message).dependent(:destroy) }
  end

  context :validations do
    it { should validate_presence_of :src }
    it { should validate_presence_of :dst }
    it { should validate_presence_of :group }
  end

  context :hooks do
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
      group = create :group
      src = create :user
      dst = create :user
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

  describe :permissions do
    let(:user) { build_stubbed :user }
    subject { Ability.new user }

    describe :own_invite do
      let(:group_invite) { build_stubbed :group_invite, dst: user }

      it { should be_able_to :accept, group_invite }
      it { should be_able_to :reject, group_invite }
    end

    describe :foreign_invite do
      let(:group_invite) { build_stubbed :group_invite }

      it { should_not be_able_to :accept, group_invite }
      it { should_not be_able_to :reject, group_invite }
    end

    #let(:club) { build_stubbed :group, join_policy: join_policy }
    #let(:user) { build_stubbed :user }

    #describe :join do
      #let(:group_role) { build :group_role, user: user, group: club }

      #context :owner_invite_join do
        #let(:join_policy) { :owner_invite_join }

        #context :club_owner do
          #let(:club) { build_stubbed :group, owner: user }
          #it { should be_able_to :create, group_role }
        #end

        #context :common_user do
          #it { should_not be_able_to :create, group_role }
        #end
      #end

      #context :admin_invite_join do
        #let(:join_policy) { :admin_invite_join }

        #context :club_owner do
          #let(:club) { build_stubbed :group, owner: user }
          #it { should be_able_to :create, group_role }
        #end

        #context :common_user do
          #it { should_not be_able_to :create, group_role }
        #end
      #end

      #context :free_join_policy do
        #let(:join_policy) { :free_join }

        #context :common_user do
          #it { should be_able_to :create, group_role }
        #end

        #context :guest do
          #let(:user) { nil }
          #it { should_not be_able_to :create, group_role }
        #end
      #end
    #end

    #describe :leave do
      #let(:join_policy) { :free_join }

      #context :club_member do
        #let(:group_role) { build_stubbed :group_role, user: user, group: club }
        #it { should be_able_to :destroy, group_role }
      #end

      #context :not_member do
        #let(:group_role) { build_stubbed :group_role, group: club }

        #context :guest do
          #let(:user) { nil }
          #it { should_not be_able_to :destroy, group_role }
        #end

        #context :common_user do
          #let(:user) { nil }
          #it { should_not be_able_to :destroy, group_role }
        #end

        #context :club_owner do
          #let(:club) { build_stubbed :group, owner: user }
          #it { should_not be_able_to :destroy, group_role }
        #end
      #end
    #end
  end
end
