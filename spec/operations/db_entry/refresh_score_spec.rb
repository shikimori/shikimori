describe DbEntry::RefreshScore do
  include_context :timecop
  subject do
    described_class.call(
      entry: anime,
      global_average: global_average
    )
  end

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
  let(:new_score) { 7.3 }
  let(:scores_count) { 2 }

  before do
    allow(Animes::WeightedScore)
      .to receive(:call)
      .and_return new_score
  end

  context 'has stats' do
    before do
      scores_count.times do |i|
        create :user_rate,
          target: anime,
          status: :completed,
          score: i.odd? ? 9 : 5,
          user: create(:user)
      end

      Animes::RefreshStats.call Anime
    end

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
  end

  context 'no stats' do
    it do
      expect { subject }.to_not change anime, :score_2
    end
  end
end
