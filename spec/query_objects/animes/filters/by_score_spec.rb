describe Animes::Filters::ByScore do
  subject { described_class.call Anime.order(:id), terms }

  let!(:anime_1) { create :anime, score: 6.9 }
  let!(:anime_2) { create :anime, score: 7.0 }
  let!(:anime_3) { create :anime, score: 7.1 }

  context 'positive' do
    context '6' do
      let(:terms) { '6' }
      it { is_expected.to eq [anime_1, anime_2, anime_3] }
    end

    context '7' do
      let(:terms) { '7' }
      it { is_expected.to eq [anime_2, anime_3] }
    end
  end

  context 'negative' do
    context '!6' do
      let(:terms) { '!6' }
      it { expect { subject }.to raise_error Dry::Types::ConstraintError }
    end
  end
end
