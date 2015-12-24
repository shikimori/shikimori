require 'cancan/matchers'

describe ClubInvite do
  describe 'relations' do
    it { is_expected.to belong_to :club }
    it { is_expected.to belong_to :src }
    it { is_expected.to belong_to :dst }
    it { is_expected.to belong_to(:message).dependent :destroy }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :src }
    it { is_expected.to validate_presence_of :dst }
    it { is_expected.to validate_presence_of :club }

    let(:club) { create :club, owner: user }
    let(:user) { create :user }
    let(:club_invite) { build :club_invite, src: user, dst: user, club: club }

    describe '#banned?' do
      let!(:ban) { create :club_ban, club: club, user: user }
      before { club_invite.save }
      it { expect(club_invite.errors.messages[:base]).to eq [I18n.t('activerecord.errors.models.club_invite.attributes.base.banned')] }
    end

    describe '#invited?' do
      let!(:invite) { create :club_invite, src: user, dst: user, club_id: club.id, status: ClubInviteStatus::Accepted }
      before { club_invite.save }
      it { expect(club_invite.errors.messages[:base]).to eq [I18n.t('activerecord.errors.models.club_invite.attributes.base.invited')] }
    end

    describe '#joined?' do
      let!(:join) { create :club_role, user: user, club: club }
      before { club_invite.save }
      it { expect(club_invite.errors.messages[:base]).to eq [I18n.t('activerecord.errors.models.club_invite.attributes.base.joined')] }
    end
  end

  context 'hooks' do
    let(:club) { create :club }
    let(:src) { create :user }
    let(:dst) { create :user }

    it 'creates ClubRequet message' do
      invite = nil
      expect {
        expect {
          invite = ClubInvite.create src: src, dst: dst, club: club
        }.to change(ClubInvite, :count).by 1
      }.to change(Message, :count).by 1

      message = Message.last
      expect(message.from_id).to eq src.id
      expect(message.to_id).to eq dst.id
      expect(message.linked).to eq invite
      expect(message.kind).to eq MessageType::ClubRequest
    end

    it 'destroys its message' do
      invite = nil
      expect {
        expect {
          invite = ClubInvite.create src: src, dst: dst, club: club
        }.to change(Message, :count).by 1
        invite.destroy
      }.to change(Message, :count).by 0
    end

    it 'destroys previous rejected invites' do
      ClubInvite.create src: src, dst: dst, club: club, status: ClubInviteStatus::Rejected
      expect {
        ClubInvite.create src: src, dst: dst, club: club, status: ClubInviteStatus::Pending
      }.to change(ClubInvite, :count).by 0
    end
  end

  describe 'instance methods' do
    describe '#accept!' do
      subject(:invite) { create :club_invite, :pending }
      before { invite.accept! }

      its(:status) { is_expected.to eq ClubInviteStatus::Accepted }
      it { expect(invite.club.joined? invite.dst).to be true }
    end

    describe '#reject!' do
      subject(:invite) { create :club_invite, :pending }
      before { invite.reject! }

      its(:status) { is_expected.to eq ClubInviteStatus::Rejected }
      it { expect(invite.club.joined? invite.dst).to be false }
    end
  end

  describe 'permissions' do
    let(:user) { build_stubbed :user, :user }
    subject { Ability.new user }

    context 'existing_invite' do
      context 'own_invite' do
        let(:club_invite) { build_stubbed :club_invite, dst: user, status: status }

        context 'pending_invite' do
          let(:status) { ClubInviteStatus::Pending }
          it { is_expected.to be_able_to :accept, club_invite }
          it { is_expected.to be_able_to :reject, club_invite }
        end

        context 'accepted_invite' do
          let(:status) { ClubInviteStatus::Accepted }
          it { is_expected.to_not be_able_to :accept, club_invite }
          it { is_expected.to_not be_able_to :reject, club_invite }
        end

        context 'rejected_invite' do
          let(:status) { ClubInviteStatus::Rejected }
          it { is_expected.to_not be_able_to :accept, club_invite }
          it { is_expected.to_not be_able_to :reject, club_invite }
        end
      end

      context 'foreign_invite' do
        let(:club_invite) { build_stubbed :club_invite }

        it { is_expected.to_not be_able_to :accept, club_invite }
        it { is_expected.to_not be_able_to :reject, club_invite }
      end
    end

    context 'new_invite' do
      context 'club_member' do
        let(:club) { build_stubbed :club, member_roles: [create(:club_role, user: user)] }

        context 'from_self' do
          let(:club_invite) { build_stubbed :club_invite, src: user, club: club }
          it { is_expected.to be_able_to :create, club_invite }
        end

        context 'from_another_user' do
          let(:club_invite) { build_stubbed :club_invite }
          it { is_expected.to_not be_able_to :create, club_invite, club: club }
        end
      end

      context 'not_a_member' do
        let(:club_invite) { build_stubbed :club_invite, src: user }
        it { is_expected.to_not be_able_to :create, club_invite }
      end
    end
  end
end
