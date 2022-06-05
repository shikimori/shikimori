describe Animes::GlobalAverage do
  subject { described_class.call target_type }

  let!(:anime_1) { create :anime }
  let!(:anime_2) { create :anime }
  let!(:anime_3) { create :anime }
  let!(:manga_4) { create :manga }
  let!(:user_rate_1) { create :user_rate, target: anime_1, updated_at: 2.days.ago, score: 7 }
  let!(:user_rate_2) { create :user_rate, target: anime_2, score: 3 }
  let!(:user_rate_4) { create :user_rate, target: manga_4, score: 10 }

  context 'anime' do
    let(:target_type) { 'Anime' }
    it { is_expected.to eq 5 }
  end

  context 'manga' do
    let(:target_type) { 'Manga' }
    it { is_expected.to eq 10 }
  end
end
