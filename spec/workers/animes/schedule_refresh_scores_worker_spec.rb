describe Animes::ScheduleRefreshScoresWorker do
  subject { described_class.new.perform Anime.name }
  before do
    allow(Animes::RefreshScoresWorker).to receive :perform_async
  end

  let!(:anime_1) { create :anime }
  let!(:anime_2) { create :anime }
  let!(:anime_3) { create :anime, score_2: anime_3_score }
  let!(:manga_4) { create :manga }
  let!(:user_rate_1) { create :user_rate, target: anime_1, updated_at: 2.days.ago, score: 7 }
  let!(:user_rate_2) { create :user_rate, target: anime_2, score: 3 }
  let!(:user_rate_4) { create :user_rate, target: manga_4, score: 10 }

  context 'no scores set' do
    let(:anime_3_score) { 0 }
    it do
      expect(subject.sort).to eq [anime_1.id, anime_2.id]
      expect(Animes::RefreshScoresWorker).to have_received(:perform_async).twice
      expect(Animes::RefreshScoresWorker)
        .to have_received(:perform_async)
        .with Anime.name, anime_1.id, 5
      expect(Animes::RefreshScoresWorker)
        .to have_received(:perform_async)
        .with Anime.name, anime_2.id, 5
    end
  end

  context 'has some scores' do
    let(:anime_3_score) { 1 }
    it do
      expect(subject).to eq [anime_2.id]
      expect(Animes::RefreshScoresWorker)
        .to have_received(:perform_async)
        .once
        .with Anime.name, anime_2.id, 5
    end
  end
end
