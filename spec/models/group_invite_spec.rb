
require 'spec_helper'

describe GroupInvite do
  it { should belong_to :group }
  it { should belong_to :src }
  it { should belong_to :dst }
  it { should belong_to :message }

  describe 'hooks' do
    let(:group) { FactoryGirl.create :group }
    let(:src) { FactoryGirl.create :user }
    let(:dst) { FactoryGirl.create :user }

    it 'creates GroupRequet message' do
      invite = nil
      expect {
        expect {
          invite = GroupInvite.create :src => src, :dst => dst, :group => group
        }.to change(GroupInvite, :count).by(1)
      }.to change(Message, :count).by(1)
      message = Message.last
      message.src_id.should be(src.id)
      message.src_type.should == src.class.name
      message.dst_id.should be(dst.id)
      message.dst_type.should == dst.class.name
      message.subject.should be(invite.id)
      message.kind.should == MessageType::GroupRequest
    end

    it 'destroys its message' do
      group = FactoryGirl.create :group
      src = FactoryGirl.create :user
      dst = FactoryGirl.create :user
      invite = nil
      expect {
        expect {
          invite = GroupInvite.create :src => src, :dst => dst, :group => group
        }.to change(Message, :count).by(1)
        invite.destroy
      }.to change(Message, :count).by(0)
    end

    it 'destroys previous rejected invites' do
      GroupInvite.create :src => src, :dst => dst, :group => group, :status => GroupInviteStatus::Rejected
      expect {
        GroupInvite.create :src => src, :dst => dst, :group => group, :status => GroupInviteStatus::Pending
      }.to change(GroupInvite, :count).by(0)
    end
  end
end
