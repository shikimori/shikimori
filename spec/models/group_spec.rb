require 'spec_helper'
require 'cancan/matchers'

describe Group do
  context :relations do
    it { should have_many :member_roles }
    it { should have_many :members }

    #it { should have_many :moderator_roles }
    #it { should have_many :moderators }

    it { should have_many :admin_roles }
    it { should have_many :admins }

    it { should have_many :links }
    it { should have_many :animes }
    it { should have_many :characters }

    it { should have_many :images }

    it { should belong_to :owner }

    it { should have_many :invites }
    it { should have_many :bans }
    it { should have_many :banned_users }

    it { should have_attached_file :logo }
  end

  describe :callbacks do
    let(:club) { build :group, :with_owner_join }
    before { club.save }
    it { expect(club.joined? club.owner).to be true }
  end

  describe :instance_methods do
    let(:user) { create :user }

    describe '#ban' do
      let(:user) { create :user }
      let(:group) { create :group }
      before { group.ban user }

      it { expect(group.banned? user).to be true }
    end

    describe '#join' do
      let(:user) { create :user }
      let(:group) { create :group }
      before { group.join user }

      context :common_user do
        it { expect(group.joined? user).to be true }
        it { expect(group.admin? user).to be false }
      end

      context :club_owner do
        let(:group) { create :group, owner: user }
        it { expect(group.admin? user).to be true }
      end
    end

    describe '#leave' do
      let(:user) { create :user }
      let(:group) { create :group }
      let(:group_role) { create :group_role, user: user, group: group }
      before { group.leave user }

      it { expect(group.joined? user).to be false }
    end

    describe '#member_role' do
      let(:user) { build_stubbed :user }
      let(:group) { build_stubbed :group, member_roles: [group_role] }
      let(:group_role) { build_stubbed :group_role, user: user }
      subject { group.member_role user }

      it { should eq group_role }
    end

    describe '#joined?' do
      let(:group) { build_stubbed :group }
      let(:user) { build_stubbed :user }
      subject { group.joined? user }

      context :just_owner do
        let(:group) { build_stubbed :group, owner: user }
        it { should be false }
      end

      context :is_admin do
        let(:group) { build_stubbed :group, member_roles: [build_stubbed(:group_role, :member, user: user)] }
        it { should be true }
      end

      context :not_a_member do
        it { should be false }
      end
    end

    describe '#admin?' do
      let(:group) { build_stubbed :group }
      let(:user) { build_stubbed :user }
      subject { group.admin? user }

      context :just_owner do
        let(:group) { build_stubbed :group, owner: user }
        it { should be false }
      end

      context :is_admin do
        let(:group) { build_stubbed :group, member_roles: [build_stubbed(:group_role, :admin, user: user)] }
        it { should be true }
      end

      context :not_a_member do
        it { should be false }
      end
    end

    describe '#owner?' do
      let(:group) { build_stubbed :group }
      let(:user) { build_stubbed :user }
      subject { group.owner? user }

      context :is_owner do
        let(:group) { build_stubbed :group, owner: user }
        it { should be true }
      end

      context :not_an_owner do
        it { should be false }
      end
    end

    describe '#invited?' do
      let(:group) { build_stubbed :group }
      let(:user) { build_stubbed :user }
      subject { group.invited? user }

      context :invited do
        let(:group) { build_stubbed :group, invites: [build_stubbed(:group_invite, dst: user)] }
        it { should be true }
      end

      context :not_invited do
        it { should be false }
      end
    end
  end

  describe :permissions do
    let(:club) { build_stubbed :group, join_policy: join_policy }
    let(:user) { build_stubbed :user }
    let(:join_policy) { :free_join }
    subject { Ability.new user }

    context :club_owner do
      let(:group_role) { build_stubbed :group_role, :admin, user: user }
      let(:club) { build_stubbed :group, owner: user, join_policy: join_policy, member_roles: [group_role] }
      it { should be_able_to :read_club, club }
      it { should be_able_to :update, club }
      it { should be_able_to :upload, club }

      describe :invite do
        context :free_join do
          let(:join_policy) { :free_join }
          it { should be_able_to :invite, club }
        end

        context :admin_invite_join do
          let(:join_policy) { :admin_invite_join }
          it { should be_able_to :invite, club }
        end

        context :owner_invite_join do
          let(:join_policy) { :owner_invite_join }
          it { should be_able_to :invite, club }
        end
      end
    end

    context :club_administrator do
      let(:group_role) { build_stubbed :group_role, :admin, user: user }
      let(:club) { build_stubbed :group, member_roles: [group_role], join_policy: join_policy }

      it { should be_able_to :read_club, club }
      it { should be_able_to :update, club }
      it { should be_able_to :upload, club }

      describe :invite do
        context :free_join do
          let(:join_policy) { :free_join }
          it { should be_able_to :invite, club }
        end

        context :admin_invite_join do
          let(:join_policy) { :admin_invite_join }
          it { should be_able_to :invite, club }
        end

        context :owner_invite_join do
          let(:join_policy) { :owner_invite_join }
          it { should_not be_able_to :invite, club }
        end
      end
    end

    context :club_member do
      let(:group_role) { build_stubbed :group_role, user: user }
      let(:club) { build_stubbed :group, member_roles: [group_role], join_policy: join_policy, upload_policy: upload_policy }
      let(:upload_policy) { GroupUploadPolicy::ByMembers }
      it { should be_able_to :leave, club }

      describe :upload do
        context :by_staff do
          let(:upload_policy) { GroupUploadPolicy::ByStaff }
          it { should_not be_able_to :upload, club }
        end

        context :by_members do
          let(:upload_policy) { GroupUploadPolicy::ByMembers }
          it { should be_able_to :upload, club }
        end
      end

      describe :invite do
        context :free_join do
          let(:join_policy) { :free_join }
          it { should be_able_to :invite, club }
        end

        context :admin_invite_join do
          let(:join_policy) { :admin_invite_join }
          it { should_not be_able_to :invite, club }
        end

        context :owner_invite_join do
          let(:join_policy) { :owner_invite_join }
          it { should_not be_able_to :invite, club }
        end
      end
    end

    context :guest do
      let(:user) { nil }
      it { should be_able_to :read_club, club }
      it { should_not be_able_to :new, club }
      it { should_not be_able_to :update, club }
      it { should_not be_able_to :invite, club }
      it { should_not be_able_to :upload, club }
    end

    context :user do
      it { should be_able_to :read_club, club }
      it { should be_able_to :new, club }
      it { should_not be_able_to :update, club }
      it { should_not be_able_to :invite, club }
      it { should_not be_able_to :upload, club }

      context :free_join do
        let(:join_policy) { :free_join }
        it { should be_able_to :join, club }
      end

      context :admin_invite_join do
        let(:join_policy) { :admin_invite_join }
        it { should_not be_able_to :join, club }
      end

      context :owner_invite_join do
        let(:join_policy) { :owner_invite_join }
        it { should_not be_able_to :join, club }
      end
    end
  end
end
