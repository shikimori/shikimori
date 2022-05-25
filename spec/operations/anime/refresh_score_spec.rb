describe Anime::RefreshScore do
  include_context :timecop
  subject { described_class.call anime, global_average }

  let(:anime) do
    create :anime, status,
      score_2: current_score,
      updated_at: 10.minutes.ago,
      options: options
  end
  let(:status) { %i[released ongoing].sample }
  let(:current_score) { 5.0 }
  let(:global_average) { 8.0 }
  let(:options) { [] }

  let(:scores_count) { 2 }

  before do
    scores_count.times do |i|
      create :user_rate,
        target: anime,
        status: :completed,
        score: i.odd? ? 9 : 5,
        user: create(:user)
    end

    allow(Animes::WeightedScore)
      .to receive(:call)
      .and_return new_score
  end
  let(:new_score) { 7.3 }

  context 'score has changed' do
    it do
      expect { subject }.to change(anime, :score_2).to new_score

      expect(anime.reload.updated_at).to be_within(0.1).of Time.zone.now
      expect(Animes::WeightedScore)
        .to have_received(:call)
        .with(
          number_of_scores: scores_count,
          average_user_score: 7,
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
          number_of_scores: scores_count,
          average_user_score: 7,
          global_average: global_average
        )
    end
  end

  describe 'anicheat score filter' do
    context 'filtered score 9 by 75%' do
      let(:options) { ['score_filter_9_75'] }
      let(:scores_count) { 8 }

      it do
        expect { subject }.to change(anime, :score_2).to new_score
        expect(Animes::WeightedScore)
          .to have_received(:call)
          .with(
            number_of_scores: (scores_count / 2) + ((scores_count / 2) * (1 - 0.75)),
            average_user_score: 5.8,
            global_average: global_average
          )
      end
    end

    context 'filter out all scores' do
      let(:options) { ['score_filter_9_100'] }

      it do
        expect { subject }.to change(anime, :score_2).to new_score
        expect(Animes::WeightedScore)
          .to have_received(:call)
          .with(
            number_of_scores: scores_count / 2,
            average_user_score: 5,
            global_average: global_average
          )
      end
    end
  end
end
