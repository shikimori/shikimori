describe Animes::Filters::ByGenre do
  subject { described_class.call Anime.order(:id), terms }

  let(:shounen) { create :genre }
  let(:shoujo) { create :genre }

  let!(:anime_1) { create :anime, genre_ids: [shounen.id, shoujo.id] }
  let!(:anime_2) { create :anime, genre_ids: [shounen.id] }
  let!(:anime_3) { create :anime, genre_ids: [shounen.id] }
  let!(:anime_4) { create :anime }
  let!(:anime_5) { create :anime, genre_ids: [shoujo.id] }

  context 'positive' do
    context 'shounen' do
      let(:terms) { shounen.to_param }
      it { is_expected.to eq [anime_1, anime_2, anime_3] }
    end

    context 'shoujo' do
      let(:terms) { shoujo.to_param }
      it { is_expected.to eq [anime_1, anime_5] }
    end

    context 'shounen, shoujo' do
      let(:terms) { "#{shounen.to_param},#{shoujo.to_param}" }
      it { is_expected.to eq [anime_1] }
    end
  end

  context 'negative' do
    context '!shounen' do
      let(:terms) { "!#{shounen.to_param}" }
      it { is_expected.to eq [anime_4, anime_5] }
    end

    context '!shoujo' do
      let(:terms) { "!#{shoujo.to_param}" }
      it { is_expected.to eq [anime_2, anime_3, anime_4] }
    end

    context '!shounen,!shoujo' do
      let(:terms) { "!#{shoujo.to_param},!#{shounen.to_param}" }
      it { is_expected.to eq [anime_4] }
    end
  end

  context 'both' do
    context 'shounen,!shoujo' do
      let(:terms) { "#{shounen.to_param},!#{shoujo.to_param}" }
      it { is_expected.to eq [anime_2, anime_3] }
    end

    context '!shounen,shoujo' do
      let(:terms) { "!#{shounen.to_param},#{shoujo.to_param}" }
      it { is_expected.to eq [anime_5] }
    end
  end
end
