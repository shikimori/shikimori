describe Animes::WeightedScore do
  subject do
    described_class.call(
      number_of_scores: number_of_scores,
      average_user_score: average_user_score,
      global_average: global_average
    )
  end

  let(:number_of_scores) { Animes::WeightedScore::MIN_SCORES }
  let(:average_user_score) { 9 }
  let(:global_average) { 8 }

  it { is_expected.to eq 8.5 }

  context 'number_of_scores' do
    let(:number_of_scores) { Animes::WeightedScore::MIN_SCORES * 2 }
    it { is_expected.to eq 8.67 }

    context 'no enough scores' do
      let(:number_of_scores) { Animes::WeightedScore::MIN_SCORES - 1 }
      it { is_expected.to eq 0 }
    end
  end

  context 'average_user_score' do
    let(:average_user_score) { 10 }
    it { is_expected.to eq 9 }
  end

  context 'global_average' do
    let(:global_average) { 7 }
    it { is_expected.to eq 8 }
  end
end
