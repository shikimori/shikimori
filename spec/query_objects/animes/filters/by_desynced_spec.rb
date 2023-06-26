describe Animes::Filters::ByDesynced do
  subject { described_class.call Anime.order(:id), terms }

  let!(:anime_1) { create :anime, desynced: %w[name poster] }
  let!(:anime_2) { create :anime, desynced: %w[poster russian] }

  context 'positive' do
    context 'name' do
      let(:terms) { 'name' }
      it { is_expected.to eq [anime_1] }
    end

    context 'poster' do
      let(:terms) { 'poster' }
      it { is_expected.to eq [anime_1, anime_2] }
    end

    context 'russian' do
      let(:terms) { 'russian' }
      it { is_expected.to eq [anime_2] }
    end
  end

  context 'negative' do
    context '!name' do
      let(:terms) { '!name' }
      it { is_expected.to eq [anime_2] }
    end

    context '!poster' do
      let(:terms) { '!poster' }
      it { is_expected.to eq [] }
    end
  end
end
