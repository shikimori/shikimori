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
      expect do
        expect do
          invite = ClubInvite.create src: src, dst: dst, club: club
        end.to change(ClubInvite, :count).by 1
      end.to change(Message, :count).by 1

      message = Message.last
      expect(message.from_id).to eq src.id
      expect(message.to_id).to eq dst.id
      expect(message.linked).to eq invite
      expect(message.kind).to eq MessageType::ClubRequest
    end

    it 'destroys its message' do
      invite = nil
      expect do
        expect do
          invite = ClubInvite.create src: src, dst: dst, club: club
        end.to change(Message, :count).by 1
        invite.destroy
      end.to change(Message, :count).by 0
    end

    it 'destroys previous rejected invites' do
      ClubInvite.create src: src, dst: dst, club: club, status: ClubInviteStatus::Rejected
      expect do
        ClubInvite.create src: src, dst: dst, club: club, status: ClubInviteStatus::Pending
      end.to change(ClubInvite, :count).by 0
    end
  end

  describe 'instance methods' do
    describe '#accept' do
      let(:invite) { create :club_invite, status }
      before { invite.accept }

      context 'pending' do
        let(:status) { :pending }
        it do
          expect(invite.status).to eq ClubInviteStatus::Accepted
          expect(invite.club.member?(invite.dst)).to eq true
          expect(invite.message.read).to eq true
        end
      end

      context 'accepted' do
        let(:status) { :accepted }
        it do
          expect(invite.status).to eq ClubInviteStatus::Accepted
          expect(invite.club.member?(invite.dst)).to eq false
          expect(invite.message.read).to eq true
        end
      end

      context 'rejected' do
        let(:status) { :rejected }
        it do
          expect(invite.status).to eq ClubInviteStatus::Rejected
          expect(invite.club.member?(invite.dst)).to eq false
          expect(invite.message.read).to eq true
        end
      end
    end

    describe '#reject' do
      let(:invite) { create :club_invite, status }
      before { invite.reject }

      context 'pending' do
        let(:status) { :pending }
        it do
          expect(invite.status).to eq ClubInviteStatus::Rejected
          expect(invite.club.member?(invite.dst)).to eq false
          expect(invite.message.read).to eq true
        end
      end

      context 'accepted' do
        let(:status) { :accepted }
        it do
          expect(invite.status).to eq ClubInviteStatus::Accepted
          expect(invite.club.member?(invite.dst)).to eq false
          expect(invite.message.read).to eq true
        end
      end

      context 'rejected' do
        let(:status) { :rejected }
        it do
          expect(invite.status).to eq ClubInviteStatus::Rejected
          expect(invite.club.member?(invite.dst)).to eq false
          expect(invite.message.read).to eq true
        end
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
          let(:status) { ClubInviteStatus::Pending }
          it { is_expected.to be_able_to :accept, club_invite }
          it { is_expected.to be_able_to :reject, club_invite }
        end

        context 'accepted invite' do
          let(:status) { ClubInviteStatus::Accepted }
          it { is_expected.to be_able_to :accept, club_invite }
          it { is_expected.to be_able_to :reject, club_invite }
        end

        context 'rejected invite' do
          let(:status) { ClubInviteStatus::Rejected }
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
