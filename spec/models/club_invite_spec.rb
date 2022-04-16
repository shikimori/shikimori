describe ClubInvite do
  describe 'relations' do
    it { is_expected.to belong_to :club }
    it { is_expected.to belong_to :src }
    it { is_expected.to belong_to :dst }
    it { is_expected.to belong_to(:message).optional.dependent :destroy }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:status).in(*Types::ClubInvite::Status.values) }
  end

  describe 'validations' do
    describe 'uniqueness validation' do
      let(:club_invite) { build :club_invite, dst: to, club: club }
      let(:to) { user }
      let!(:club_invite_2) { create :club_invite, dst: to, club: club }

      before { club_invite.save }

      it do
        expect(club_invite.errors.messages[:dst_id]).to eq [
          I18n.t('activerecord.errors.models.club_invite.attributes.dst_id.taken')
        ]
      end
    end
  end

  context 'callbacks' do
    let(:club_invite) do
      build :club_invite, src: from, dst: to, club: club, status: status
    end
    let(:from) { user }
    let(:to) { user_2 }
    let(:status) { Types::ClubInvite::Status[:pending] }

    describe '#check_banned' do
      let!(:ban) { create :club_ban, club: club, user: to }
      before { club_invite.save }
      it do
        expect(club_invite.errors.messages[:base]).to eq [
          I18n.t('activerecord.errors.models.club_invite.attributes.base.banned')
        ]
      end
    end

    describe '#check_joined' do
      let!(:club_role) { create :club_role, user: to, club: club }
      before { club_invite.save }
      it do
        expect(club_invite.errors.messages[:base]).to eq [
          I18n.t('activerecord.errors.models.club_invite.attributes.base.joined')
        ]
      end
    end

    describe '#create_message' do
      let(:club_invite) { create :club_invite, src: from, dst: to, club: club }
      let(:message) { club_invite.message }

      it do
        expect(message.from).to eq from
        expect(message.to).to eq to
        expect(message.linked).to eq club_invite
        expect(message.kind).to eq MessageType::CLUB_REQUEST
      end
    end

    describe '#cleanup_invites' do
      let!(:club_invite_1) do
        create :club_invite, :closed, src: from, dst: to, club: club
      end
      let!(:club_invite_2) do
        create :club_invite, :closed, src: from, dst: from, club: club
      end
      let!(:club_invite_3) do
        create :club_invite, :pending, src: from, dst: to, club: club
      end

      it do
        expect { club_invite_1.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(club_invite_2.reload).to be_persisted
        expect(club_invite_3.reload).to be_persisted
      end
    end

    describe '#check_user_invites' do
      before { stub_const('ClubInvite::USER_INVITES_PER_DAY', 1) }

      let!(:club_invite_1) do
        create :club_invite, :closed,
          src: club_invite_1_user,
          dst: to,
          club: club,
          created_at: club_invite_1_date
      end
      let(:club_invite_2) do
        build :club_invite, :closed, src: from, dst: from, club: club
      end

      let(:club_invite_1_user) { from }

      before { club_invite_2.save }

      context 'prior invites less than day ago' do
        let(:club_invite_1_date) { ClubInvite::INVITES_LIMIT_EXPIRATION.ago + 1.minute }

        context 'from the same user' do
          it do
            expect(club_invite_2.errors.messages[:base]).to eq [
              I18n.t('activerecord.errors.models.club_invite.attributes.base.limited')
            ]
          end
        end

        context 'from another user' do
          let(:club_invite_1_user) { user_3 }
          it { expect(club_invite_2).to be_persisted }
        end
      end

      context 'prior invites more than day ago' do
        let(:club_invite_1_date) { ClubInvite::INVITES_LIMIT_EXPIRATION.ago - 1.minute }
        it { expect(club_invite_2).to be_persisted }
      end
    end

    describe '#check_club_invites' do
      before { stub_const('ClubInvite::CLUB_INVITES_PER_DAY', 1) }

      let!(:club_invite_1) do
        create :club_invite, :closed,
          src: club_invite_1_user,
          dst: to,
          club: club,
          created_at: club_invite_1_date
      end
      let(:club_invite_2) do
        build :club_invite, :closed, src: from, dst: from, club: club
      end

      let(:club_invite_1_user) { from }

      before { club_invite_2.save }

      context 'prior invites less than day ago' do
        let(:club_invite_1_date) { ClubInvite::INVITES_LIMIT_EXPIRATION.ago + 1.minute }

        context 'from the same user' do
          it do
            expect(club_invite_2.errors.messages[:base]).to eq [
              I18n.t('activerecord.errors.models.club_invite.attributes.base.limited')
            ]
          end
        end

        context 'from another user' do
          let(:club_invite_1_user) { user_3 }
          it do
            expect(club_invite_2.errors.messages[:base]).to eq [
              I18n.t('activerecord.errors.models.club_invite.attributes.base.limited')
            ]
          end
        end
      end

      context 'prior invites more than day ago' do
        let(:club_invite_1_date) { ClubInvite::INVITES_LIMIT_EXPIRATION.ago - 1.minute }
        it { expect(club_invite_2).to be_persisted }
      end
    end
  end

  describe 'instance methods' do
    let(:from) { create :user }
    let(:to) { create :user }
    let(:invite) { create :club_invite, status, src: from, dst: to }
    let(:status) { Types::ClubInvite::Status[:pending] }

    describe '#accept!' do
      subject! { invite.accept! }

      it do
        expect(invite).to be_closed
        expect(invite.club.member?(invite.dst)).to eq true
        expect(invite.message.read).to eq true
      end
    end

    describe '#close!' do
      subject! { invite.close! }

      let(:status) { Types::ClubInvite::Status[:pending] }
      it do
        expect(invite).to be_closed
        expect(invite.club.member?(invite.dst)).to eq false
        expect(invite.message.read).to eq true
      end
    end
  end

  describe 'permissions' do
    let(:user) { build_stubbed :user, :user }
    subject { Ability.new user }

    context 'existing invite' do
      context 'own invite' do
        let(:club_invite) { build_stubbed :club_invite, dst: user, status: status }

        context 'pending invite' do
          let(:status) { Types::ClubInvite::Status[:pending] }
          it { is_expected.to be_able_to :accept, club_invite }
          it { is_expected.to be_able_to :reject, club_invite }
        end

        context 'closed invite' do
          let(:status) { Types::ClubInvite::Status[:closed] }
          it { is_expected.to be_able_to :accept, club_invite }
          it { is_expected.to be_able_to :reject, club_invite }
        end
      end

      context 'foreign invite' do
        let(:club_invite) { build_stubbed :club_invite }

        it { is_expected.to_not be_able_to :accept, club_invite }
        it { is_expected.to_not be_able_to :reject, club_invite }
      end
    end

    context 'new_invite' do
      context 'club member' do
        let(:club) { build_stubbed :club, member_roles: [create(:club_role, user: user)] }

        context 'from self' do
          let(:club_invite) { build_stubbed :club_invite, src: user, club: club }
          it { is_expected.to be_able_to :create, club_invite }
        end

        context 'from another user' do
          let(:club_invite) { build_stubbed :club_invite }
          it { is_expected.to_not be_able_to :create, club_invite, club: club }
        end
      end

      context 'not a member' do
        let(:club_invite) { build_stubbed :club_invite, src: user }
        it { is_expected.to_not be_able_to :create, club_invite }
      end
    end
  end
end
