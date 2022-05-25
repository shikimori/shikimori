describe Anime::RefreshScore do
  include_context :timecop
  subject { described_class.call anime, global_average }

  let(:anime) do
    create :anime, status,
      score_2: current_score,
      updated_at: 10.minutes.ago
  end
  let(:status) { %i[released ongoing].sample }
  let(:current_score) { 5.0 }
  let(:global_average) { 8.0 }

  Animes::WeightedScore::MIN_SCORES.times do |i|
    let(:"user_#{i + 1}") { create :user }
  end

  Animes::WeightedScore::MIN_SCORES.times do |i|
    let!(:"anime_rate_#{i + 1}".to_sym) do
      create :user_rate,
        target: anime,
        status: :completed,
        score: 9,
        user: send(:"user_#{i + 1}") # user_1
    end
  end

  before do
    allow(Animes::WeightedScore)
      .to receive(:call)
      .and_return new_score
  end

  context 'score has changed' do
    let(:new_score) { 1.3 }
    it do
      expect { subject }.to change(anime, :score_2).to new_score

      expect(anime.reload.updated_at).to be_within(0.1).of Time.zone.now
      expect(Animes::WeightedScore)
        .to have_received(:call)
        .with(
          number_of_scores: Animes::WeightedScore::MIN_SCORES,
          average_user_score: 9,
          global_average: global_average
        )
    end

    context 'anons' do
      let(:status) { :anons }
      it do
        expect { subject }.to change(anime, :score_2).to 0
      end
    end
  end

  context 'score has not changed' do
    let(:new_score) { current_score }
    it do
      expect { subject }.to_not change(anime, :score_2)

      expect(anime.reload.updated_at).to be_within(0.1).of 10.minutes.ago
      expect(Animes::WeightedScore)
        .to have_received(:call)
        .with(
          number_of_scores: Animes::WeightedScore::MIN_SCORES,
          average_user_score: 9,
          global_average: global_average
        )
    end
  end
end
