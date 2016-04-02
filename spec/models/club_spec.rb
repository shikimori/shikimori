require 'cancan/matchers'

describe Club do
  describe 'relations' do
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
  end

  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :owner }
    it { should have_attached_file :logo }
  end

  describe 'callbacks' do
    before { club.save }

    describe '#join_owner' do
      let(:club) { build :club, :with_owner_join }
      it { expect(club.joined? club.owner).to eq true }
    end

    describe '#generate_topic' do
      let(:club) { build :club, :with_topic }
      it { expect(club.topic).to be_present }
    end
  end

  describe 'instance methods' do
    let(:user) { create :user }

    describe '#ban' do
      let(:user) { create :user }
      let(:club) { create :club }
      before { club.ban user }

      it { expect(club.banned? user).to be true }
    end

    describe '#join' do
      let(:user) { create :user }
      let(:club) { create :club }
      before { club.join user }

      it { expect(club.reload.club_roles_count).to eq 1 }
      it { expect(club.joined? user).to be true }

      context 'user' do
        it { expect(club.admin? user).to be_falsy }
      end

      context 'club_owner' do
        let(:club) { create :club, owner: user }
        it { expect(club.admin? user).to be_truthy }
      end

      describe '#leave' do
        before { club.reload.leave user }

        it { expect(club.joined? user).to be false }
        it { expect(club.reload.club_roles_count).to be_zero }
      end
    end

    describe '#member_role' do
      let(:user) { build_stubbed :user }
      let(:club) { build_stubbed :club, member_roles: [club_role] }
      let(:club_role) { build_stubbed :club_role, user: user }
      subject { club.member_role user }

      it { should eq club_role }
    end

    describe '#joined?' do
      let(:club) { build_stubbed :club }
      let(:user) { build_stubbed :user }
      subject { club.joined? user }

      context "owner" do
        let(:club) { build_stubbed :club, owner: user }
        it { should be false }
      end

      context 'admin' do
        let(:club) { build_stubbed :club, member_roles: [build_stubbed(:club_role, :member, user: user)] }
        it { should be true }
      end

      context "not a member" do
        it { should be false }
      end
    end

    describe '#admin?' do
      let(:club) { build_stubbed :club }
      let(:user) { build_stubbed :user }
      subject { club.admin? user }

      context 'just owner' do
        let(:club) { build_stubbed :club, owner: user }
        it { should be false }
      end

      context 'is admin' do
        let(:club) { build_stubbed :club, member_roles: [build_stubbed(:club_role, :admin, user: user)] }
        it { should be true }
      end

      context 'not a member' do
        it { should be false }
      end
    end

    describe '#owner?' do
      let(:club) { build_stubbed :club }
      let(:user) { build_stubbed :user }
      subject { club.owner? user }

      context 'is owner' do
        let(:club) { build_stubbed :club, owner: user }
        it { should be true }
      end

      context 'not an owner' do
        it { should be false }
      end
    end

    describe '#invited?' do
      let(:club) { build_stubbed :club }
      let(:user) { build_stubbed :user }
      subject { club.invited? user }

      context 'invited' do
        let(:club) { build_stubbed :club, invites: [build_stubbed(:club_invite, dst: user)] }
        it { should be true }
      end

      context 'not invited' do
        it { should be false }
      end
    end
  end

  describe 'permissions' do
    let(:club) { build_stubbed :club, join_policy: join_policy }
    let(:user) { build_stubbed :user, :user, :day_registered }
    let(:join_policy) { :free_join }
    subject { Ability.new user }

    context 'club owner' do
      let(:club_role) { build_stubbed :club_role, :admin, user: user }
      let(:club) { build_stubbed :club, owner: user, join_policy: join_policy, member_roles: [club_role] }
      it { should be_able_to :see_club, club }

      context 'newly registered' do
        let(:user) { build_stubbed :user, :user }
        it { should_not be_able_to :new, club }
        it { should_not be_able_to :create, club }
      end

      context 'not banned' do
        it { should be_able_to :update, club }
        it { should be_able_to :upload, club }
        it { should be_able_to :new, club }
        it { should be_able_to :create, club }
      end

      context 'banned' do
        let(:user) { build_stubbed :user, :user, :banned }
        it { should_not be_able_to :update, club }
        it { should_not be_able_to :upload, club }
        it { should_not be_able_to :new, club }
        it { should_not be_able_to :create, club }
      end

      describe 'invite' do
        context 'free_join' do
          let(:join_policy) { :free_join }
          it { should be_able_to :invite, club }
        end

        context 'admin_invite_join' do
          let(:join_policy) { :admin_invite_join }
          it { should be_able_to :invite, club }
        end

        context 'owner_invite_join' do
          let(:join_policy) { :owner_invite_join }
          it { should be_able_to :invite, club }
        end
      end
    end

    context 'club administrator' do
      let(:club_role) { build_stubbed :club_role, :admin, user: user }
      let(:club) { build_stubbed :club, member_roles: [club_role], join_policy: join_policy }

      it { should be_able_to :see_club, club }

      context 'not banned' do
        it { should be_able_to :update, club }
        it { should be_able_to :upload, club }
      end

      context 'banned' do
        let(:user) { build_stubbed :user, :user, :banned }
        it { should_not be_able_to :update, club }
        it { should_not be_able_to :upload, club }
      end

      describe 'invite' do
        context 'free_join' do
          let(:join_policy) { :free_join }
          it { should be_able_to :invite, club }
        end

        context 'admin_invite_join' do
          let(:join_policy) { :admin_invite_join }
          it { should be_able_to :invite, club }
        end

        context 'owner_invite_join' do
          let(:join_policy) { :owner_invite_join }
          it { should_not be_able_to :invite, club }
        end
      end
    end

    context 'club member' do
      let(:club_role) { build_stubbed :club_role, user: user }
      let(:club) { build_stubbed :club, member_roles: [club_role], join_policy: join_policy, upload_policy: upload_policy, display_images: display_images }
      let(:upload_policy) { ClubUploadPolicy::ByMembers }
      let(:display_images) { true }
      it { should be_able_to :leave, club }

      describe 'upload' do
        context 'by_staff' do
          let(:upload_policy) { ClubUploadPolicy::ByStaff }
          it { should_not be_able_to :upload, club }
        end

        context 'by_members' do
          let(:upload_policy) { ClubUploadPolicy::ByMembers }

          context 'display_images' do
            it { should be_able_to :upload, club }
          end

          context 'do not display_images' do
            let(:display_images) { false }
            it { should_not be_able_to :upload, club }
          end
        end
      end

      describe 'invite' do
        context 'free_join' do
          let(:join_policy) { :free_join }
          it { should be_able_to :invite, club }
        end

        context 'admin_invite_join' do
          let(:join_policy) { :admin_invite_join }
          it { should_not be_able_to :invite, club }
        end

        context 'owner_invite_join' do
          let(:join_policy) { :owner_invite_join }
          it { should_not be_able_to :invite, club }
        end
      end
    end

    context 'guest' do
      let(:user) { nil }
      it { should be_able_to :see_club, club }
      it { should_not be_able_to :new, club }
      it { should_not be_able_to :update, club }
      it { should_not be_able_to :invite, club }
      it { should_not be_able_to :upload, club }
    end

    context 'user' do
      it { should be_able_to :see_club, club }
      it { should_not be_able_to :new, club }
      it { should_not be_able_to :update, club }
      it { should_not be_able_to :invite, club }
      it { should_not be_able_to :upload, club }

      context 'free_join' do
        let(:join_policy) { :free_join }
        it { should be_able_to :join, club }
      end

      context 'admin_invite_join' do
        let(:join_policy) { :admin_invite_join }
        it { should_not be_able_to :join, club }
      end

      context 'owner_invite_join' do
        let(:join_policy) { :owner_invite_join }
        it { should_not be_able_to :join, club }
      end
    end
  end
end
