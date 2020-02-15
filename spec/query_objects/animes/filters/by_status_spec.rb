describe Animes::Filters::ByStatus do
  subject { described_class.call Anime.order(:id), terms }

  let!(:anime_1) { create :anime, :ongoing, aired_on: Time.zone.now - 1.month }

  let!(:anime_2) { create :anime, :anons }
  let!(:anime_3) { create :anime, :anons }

  let!(:anime_4) { create :anime, :released }
  let!(:anime_5) do
    create :anime, :released, released_on: described_class::LATEST_INTERVAL.ago - 1.day
  end

  let!(:anime_6) do
    create :anime, :released, released_on: described_class::LATEST_INTERVAL.ago + 1.day
  end

  context 'positive' do
    context 'ongoing' do
      let(:terms) { 'ongoing' }
      it { is_expected.to eq [anime_1] }
    end

    context 'latest' do
      let(:terms) { 'latest' }
      it { is_expected.to eq [anime_6] }
    end

    context 'anons' do
      let(:terms) { 'anons' }
      it { is_expected.to eq [anime_2, anime_3] }
    end

    context 'released' do
      let(:terms) { 'released' }
      it { is_expected.to eq [anime_4, anime_5, anime_6] }
    end

    context 'ongoing,anons' do
      let(:terms) { 'ongoing,anons' }
      it { is_expected.to eq [anime_1, anime_2, anime_3] }
    end
  end

  context 'negative' do
    context '!ongoing' do
      let(:terms) { '!ongoing' }
      it { is_expected.to eq [anime_2, anime_3, anime_4, anime_5, anime_6] }
    end

    context '!anons,!released' do
      let(:terms) { '!anons,!released' }
      it { is_expected.to eq [anime_1] }
    end
  end

  context 'both' do
    context 'ongoing' do
      let(:terms) { '!anons,ongoing' }
      it { is_expected.to eq [anime_1] }
    end
  end
end
