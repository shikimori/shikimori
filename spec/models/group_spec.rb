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

    it { should have_attached_file :logo }
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
        it { expect(group.has_member? user).to be true }
        it { expect(group.has_admin? user).to be false }
      end

      context :club_owner do
        let(:group) { create :group, owner: user }
        it { expect(group.has_admin? user).to be true }
      end
    end

    describe '#leave' do
      let(:user) { create :user }
      let(:group) { create :group }
      let(:group_role) { create :group_role, user: user, group: group }
      before { group.leave user }

      it { expect(group.has_member? user).to be false }
    end

    describe '#member_role' do
      let(:user) { build_stubbed :user }
      let(:group) { build_stubbed :group, member_roles: [group_role] }
      let(:group_role) { build_stubbed :group_role, user: user }
      subject { group.member_role user }

      it { should eq group_role }
    end

    describe '#has_member?' do
      let(:group) { build_stubbed :group }
      let(:user) { build_stubbed :user }
      subject { group.has_member? user }

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

    describe '#has_admin?' do
      let(:group) { build_stubbed :group }
      let(:user) { build_stubbed :user }
      subject { group.has_admin? user }

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

    describe '#has_owner?' do
      let(:group) { build_stubbed :group }
      let(:user) { build_stubbed :user }
      subject { group.has_owner? user }

      context :is_owner do
        let(:group) { build_stubbed :group, owner: user }
        it { should be true }
      end

      context :not_an_owner do
        it { should be false }
      end
    end
  end

  describe :permissions do
    let(:club) { build_stubbed :group }
    let(:user) { build_stubbed :user }
    subject { Ability.new user }

    context :club_owner do
      let(:club) { build_stubbed :group, owner: user }
      it { should be_able_to :manage, club }
    end

    context :club_administrator do
      let(:user) { create :user }
      let(:club) { create :group, :with_thread }
      let!(:group_role) { create :group_role, :admin, group: club, user: user }
      it { should be_able_to :manage, club }
    end

    context :guest do
      let(:user) { nil }
      it { should be_able_to :read_group, club }
      it { should_not be_able_to :manage, club }
    end

    context :user do
      it { should be_able_to :read_group, club }
      it { should_not be_able_to :manage, club }
    end
  end
end
