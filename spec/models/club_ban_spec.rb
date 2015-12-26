describe ClubBan do
  describe 'relations' do
    it { is_expected.to belong_to :club }
    it { is_expected.to belong_to :user }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :club }
    it { is_expected.to validate_presence_of :user }
  end

  describe 'callbacks' do
    let(:user) { create :user }
    let(:club) { create :club }

    context 'member' do
      let!(:club_role) { create :club_role, user: user, club: club }
      let!(:outgoing_invite) { create :club_invite, src: user,
        club: club, dst_id: club.owner_id }
      before { create :club_ban, club: club, user: user }

      it { expect(club.reload.joined? user).to eq false }
      it { expect(club.invites).to be_empty }
    end

    context 'not a member' do
      let!(:incoming_invite) { create :club_invite, dst: user,
        club: club, src_id: club.owner_id }
      before { create :club_ban, club: club, user: user }
      it { expect(club.invites).to be_empty }
    end
  end
end
