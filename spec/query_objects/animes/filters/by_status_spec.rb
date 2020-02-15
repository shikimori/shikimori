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
      it { is_expected.to have(1).item }
    end

    context 'latest' do
      let(:terms) { 'latest' }
      it { is_expected.to have(1).item }
    end

    context 'anons' do
      let(:terms) { 'anons' }
      it { is_expected.to have(2).items }
    end

    context 'released' do
      let(:terms) { 'released' }
      it { is_expected.to have(3).items }
    end

    context 'ongoing,anons' do
      let(:terms) { 'ongoing,anons' }
      it { is_expected.to have(3).items }
    end
  end

  context 'negative' do
    context '!ongoing' do
      let(:terms) { '!ongoing' }
      it { is_expected.to have(5).items }
    end

    context '!anons,!released' do
      let(:terms) { '!anons,!released' }
      it { is_expected.to have(1).item }
    end
  end

  context 'both' do
    context 'ongoing' do
      let(:terms) { '!anons,ongoing' }
      it { is_expected.to have(1).item }
    end
  end
end
