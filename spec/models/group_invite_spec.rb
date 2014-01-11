
require 'spec_helper'

describe GroupInvite do
  it { should belong_to :group }
  it { should belong_to :src }
  it { should belong_to :dst }
  it { should belong_to :message }

  describe 'hooks' do
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
      message.from_id.should be src.id
      message.to_id.should be dst.id
      message.subject.should be invite.id
      message.kind.should == MessageType::GroupRequest
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
end
