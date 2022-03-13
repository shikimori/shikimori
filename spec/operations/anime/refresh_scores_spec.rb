describe Anime::RefreshScores do
  subject { described_class.call anime, global_average }

  let(:anime) { create :anime }
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

  context 'anime score_2 changed' do
    it do
      expect { subject }.to change(anime, :score_2).to 8.5
    end
  end
end
