describe ApplyRatedEntries do
  let(:service) { ApplyRatedEntries.new user }

  let(:user) { seed :user }
  let!(:anime_1) { create :anime }
  let!(:anime_2) { create :anime }

  let!(:rate_2) { create :user_rate, user: user, anime: anime_2 }

  describe '#apply' do
    let(:collection) { [anime_1, anime_2] }
    let(:result) { service.call collection }

    it do
      expect(result.first).to be_kind_of RatedEntry
      expect(result.second).to be_kind_of RatedEntry

      expect(result.first.rate).to eq nil
      expect(result.second.rate).to have_attributes(
        id: rate_2.id,
        target_id: rate_2.target_id,
        status: rate_2.status,
        score: rate_2.score
      )
    end
  end
end
