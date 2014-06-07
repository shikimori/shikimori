require 'spec_helper'

describe Group do
  context :relations do
    it { should have_many :member_roles }
    it { should have_many :members }

    it { should have_many :moderator_roles }
    it { should have_many :moderators }

    it { should have_many :admin_roles }
    it { should have_many :admins }

    it { should have_many :links }
    it { should have_many :animes }
    it { should have_many :characters }

    it { should have_many :images }

    it { should belong_to :owner }

    it { should have_many :invites }
    it { should have_many :bans }

    it { should have_attached_file :logo }
  end

  let(:user) { create :user }

  describe Image do
    it "can't be deleted by random user" do
      group = create :group
      image = create :image, owner: group, uploader: user

      group.can_delete_images?(user).should eq(false)
    end

    it 'can be deleted by staff' do
      group = create :group
      group.moderators << user
      image = create :image, owner: group, uploader: user

      group.can_delete_images?(user).should eq(true)
    end
  end

  describe 'with Free join_policy' do
    let(:group) { create :group, :free_join }

    it 'can be joined by random user' do
      group.can_be_joined_by?(user).should eq(true)
    end

    it 'has a member' do
      group.member?(user).should eq(false)

      group.members << user
      group.member?(user).should eq(true)
    end

    it 'has a staff' do
      group.moderators << user
      user2 = create :user
      group.admins << user2

      group.staff?(user).should eq(true)
      group.staff?(user2).should eq(true)
    end

    it 'can be moderated by moderators and admins' do
      moderator = create :user
      group.moderators << moderator

      admin = create :user
      group.admins << admin

      group.can_be_edited_by?(user).should eq(false)
      group.can_be_edited_by?(moderator).should eq(true)
      group.can_be_edited_by?(admin).should eq(true)
    end

    it 'random member can send invites' do
      group.members << user
      group.can_send_invites?(user).should eq(true)
    end
  end

  describe 'with ByOwnerInvite join_policy' do
    let(:group) { create :group, :owner_invite_join }

    it "can't be joined by user" do
      group.can_be_joined_by?(user).should eq(false)
    end

    it "can be joined by owner" do
      group.owner = user
      group.can_be_joined_by?(user).should eq(true)
    end

    it "random member can't send invites" do
      group.members << user
      group.can_send_invites?(user).should eq(false)
    end

    it 'owner member can send invites' do
      group.owner_id = user.id
      group.members << user
      group.can_send_invites?(user).should eq(true)
    end
  end

  describe 'with ByMembers upload_policy' do
    let(:group) { create :group, upload_policy: GroupUploadPolicy::ByMembers }

    it "can't be uploaded by random users" do
      group.can_be_uploaded_by?(user).should be(false)
    end

    it "can be uploaded by member" do
      group.members << user
      group.can_be_uploaded_by?(user).should be(true)
    end

    it "can be uploaded by admin" do
      group.admins << user
      group.can_be_uploaded_by?(user).should be(true)
    end
  end

  describe 'with ByStaff upload_policy' do
    let(:group) { create :group, upload_policy: GroupUploadPolicy::ByStaff }

    it "can't be uploaded by random users" do
      group.can_be_uploaded_by?(user).should be(false)
    end

    it "can't be uploaded by member" do
      group.members << user
      group.can_be_uploaded_by?(user).should be(false)
    end

    it "can be uploaded by admin" do
      group.admins << user
      group.can_be_uploaded_by?(user).should be(true)
    end
  end

  describe '#ban' do
    let(:user) { create :user }
    let(:group) { create :group }
    before { group.ban user }

    it { expect(group.banned? user).to be true }
  end

  describe '#leave' do
    let(:user) { create :user }
    let(:group) { create :group }
    let(:group_role) { create :group_role, user: user, group: group }
    before { group.leave user }

    it { expect(group.member? user).to be false }
  end
end
