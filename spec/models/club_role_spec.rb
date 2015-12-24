require 'cancan/matchers'

describe ClubRole do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to(:club).touch(true) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :club }
    it { is_expected.to validate_presence_of :role }

    let(:club) { create :club }
    let(:user) { create :user }
    it 'uniq index on user_id+club_id is_expected.to work' do
      expect {
        expect {
          club.members << user
          club.members << user
        }.to raise_error(ActiveRecord::RecordNotUnique)
      }.to change(ClubRole, :count).by 1
    end
  end

  context 'invites' do
    let(:club) { create :club, owner: user2 }
    let(:user) { create :user }
    let(:user2) { create :user }

    let!(:invite) { create :club_invite, src: user2, dst: user, club: club }
    let!(:club_role) { create :club_role, club_id: club.id, user_id: user.id }

    it { expect(invite.reload.status).to eq ClubInviteStatus::Accepted }
    it { expect{club_role.destroy}.to change(ClubInvite, :count).by -1 }
  end

  describe 'permissions' do
    let(:club) { build_stubbed :club, join_policy: join_policy }
    let(:user) { build_stubbed :user, :user }
    subject { Ability.new user }

    describe 'join' do
      let(:club_role) { build :club_role, user: user, club: club }

      context 'owner_invite_join' do
        let(:join_policy) { :owner_invite_join }

        context 'club_owner' do
          let(:club) { build_stubbed :club, owner: user }
          it { is_expected.to be_able_to :create, club_role }
        end

        context 'common_user' do
          it { is_expected.to_not be_able_to :create, club_role }
        end
      end

      context 'admin_invite_join' do
        let(:join_policy) { :admin_invite_join }

        context 'club_owner' do
          let(:club) { build_stubbed :club, owner: user }
          it { is_expected.to be_able_to :create, club_role }
        end

        context 'common_user' do
          it { is_expected.to_not be_able_to :create, club_role }
        end
      end

      context 'free_join_policy' do
        let(:join_policy) { :free_join }

        context 'common_user' do
          it { is_expected.to be_able_to :create, club_role }
        end

        context 'banned_user' do
          let(:club) { build_stubbed :club, join_policy: join_policy, bans: [build_stubbed(:club_ban, user: user)] }
          it { is_expected.to_not be_able_to :create, club_role }
        end

        context 'guest' do
          let(:user) { nil }
          it { is_expected.to_not be_able_to :create, club_role }
        end
      end
    end

    describe 'leave' do
      let(:join_policy) { :free_join }

      context 'club_member' do
        let(:club_role) { build_stubbed :club_role, user: user, club: club }
        it { is_expected.to be_able_to :destroy, club_role }
      end

      context 'not_member' do
        let(:club_role) { build_stubbed :club_role, club: club }

        context 'guest' do
          let(:user) { nil }
          it { is_expected.to_not be_able_to :destroy, club_role }
        end

        context 'common_user' do
          let(:user) { nil }
          it { is_expected.to_not be_able_to :destroy, club_role }
        end

        context 'club_owner' do
          let(:club) { build_stubbed :club, owner: user }
          it { is_expected.to_not be_able_to :destroy, club_role }
        end
      end
    end
  end
end
