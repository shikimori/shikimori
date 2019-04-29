describe Users::ProfileStatsQuery do
  let(:anime) { create :anime, episodes: 24, duration: 60 }
  let(:manga) { create :manga, chapters: 54 }

  subject(:stats) { Users::ProfileStatsQuery.new user }

  describe '#to_profile_stats' do
    let!(:anime_rate) { create :user_rate, :watching, user: user, anime: anime, episodes: 12 }
    it { expect(stats.to_profile_stats.to_h).to have(17).items }
  end

  describe '#spent_time' do
    context 'watching' do
      let!(:anime_rate) { create :user_rate, :watching, user: user, anime: anime, episodes: 12 }
      it do
        expect(stats.anime_spent_time).to eq SpentTime.new(0.5)
        expect(stats.manga_spent_time).to eq SpentTime.new(0)
        expect(stats.spent_time).to eq SpentTime.new(0.5)
      end
    end

    context 'completed' do
      let!(:anime_rate) { create :user_rate, :completed, user: user, anime: anime }
      it do
        expect(stats.anime_spent_time).to eq SpentTime.new(1)
        expect(stats.manga_spent_time).to eq SpentTime.new(0)
        expect(stats.spent_time).to eq SpentTime.new(1)
      end
    end

    context 'completed & rewatched' do
      let!(:anime_rate) { create :user_rate, :completed, user: user, anime: anime, rewatches: 2 }

      it do
        expect(stats.anime_spent_time).to eq SpentTime.new(3)
        expect(stats.manga_spent_time).to eq SpentTime.new(0)
        expect(stats.spent_time).to eq SpentTime.new(3)
      end
    end

    context 'with manga' do
      let!(:anime_rate) { create :user_rate, :completed, user: user, target: anime }
      let!(:manga_rate) { create :user_rate, :completed, user: user, target: manga }

      it do
        expect(stats.anime_spent_time).to eq SpentTime.new(1.0)
        expect(stats.manga_spent_time).to eq SpentTime.new(0.3)
        expect(stats.spent_time).to eq SpentTime.new(1.3)
      end
    end
  end
end
