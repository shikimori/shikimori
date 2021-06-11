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

    before do
      allow(Elasticsearch::Query::User)
        .to receive(:call)
        .with(phrase: phrase, limit: described_class::IDS_LIMIT)
        .and_return results
    end

    subject! { described_class.new(club).complete phrase }

    context 'sample' do
      let(:phrase) { 'mo' }
      let(:results) { { user_1.id => 0.123123, user_2.id => 0.1 } }
      it { is_expected.to eq [user_1, user_2] }
    end

    context 'sample' do
      let(:phrase) { 'morr' }
      let(:results) { { user_2.id => 0.1 } }
      it { is_expected.to eq [user_2] }
    end
  end
end
