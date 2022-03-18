describe ClubRole do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to(:club).touch(true) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :role }

    context 'uniq index on user_id+club_id (twice added the same user)' do
      subject(:add_user_twice) do
        club.members << user
        club.members << user
      end

      it do
        expect { add_user_twice }
          .to raise_error(ActiveRecord::RecordNotUnique)
          .and change(ClubRole, :count).by(1)
      end
    end
  end

  context 'invites' do
    let(:user_2) { create :user }
    let(:club) { create :club, owner: user_2 }

    let!(:invite) { create :club_invite, src: user_2, dst: user, club: club }
    let!(:club_role) { create :club_role, club_id: club.id, user_id: user.id }

    it { expect(invite.reload).to be_closed }
    it { expect { club_role.destroy }.to change(ClubInvite, :count).by(-1) }
  end

  describe 'permissions' do
    let(:club) { build_stubbed :club, join_policy: join_policy }
    let(:user) { build_stubbed :user, :user }
    let(:join_policy) { Types::Club::JoinPolicy[:free] }

    subject { Ability.new user }

    describe 'join' do
      let(:club_role) { build :club_role, user: user, club: club }

      context 'owner_invite' do
        let(:join_policy) { Types::Club::JoinPolicy[:owner_invite] }

        context 'club_owner' do
          let(:club) { build_stubbed :club, owner: user }
          it { is_expected.to be_able_to :create, club_role }
        end

        context 'common_user' do
          it { is_expected.to_not be_able_to :create, club_role }
        end
      end

      context 'admin_invite' do
        let(:join_policy) { Types::Club::JoinPolicy[:admin_invite] }

        context 'club_owner' do
          let(:club) { build_stubbed :club, owner: user }
          it { is_expected.to be_able_to :create, club_role }
        end

        context 'common_user' do
          it { is_expected.to_not be_able_to :create, club_role }
        end
      end

      context 'free' do
        let(:join_policy) { Types::Club::JoinPolicy[:free] }

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
