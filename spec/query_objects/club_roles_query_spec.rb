describe ClubRolesQuery do
  describe 'complete' do
    let(:club) { create :club, owner: user_2 }
    let!(:club_role_1) { create :club_role, club: club, user: user_1 }
    let!(:club_role_2) { create :club_role, club: club, user: user_2 }
    let!(:club_role_3) { create :club_role, club: club, user: user_3 }

    let(:user_1) { create :user, nickname: 'morr' }
    let(:user_2) { create :user, nickname: 'morrrr' }
    let(:user_3) { create :user, nickname: 'zzzz' }
    let(:user_4) { create :user, nickname: 'xxxx' }

    let(:query) { ClubRolesQuery.new(club) }

    it { expect(query.complete('mo')).to eq [user_1, user_2] }
    it { expect(query.complete('morrr')).to eq [user_2] }
  end
end
