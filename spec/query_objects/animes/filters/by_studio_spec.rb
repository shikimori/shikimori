describe Animes::Filters::ByStudio do
  subject { described_class.call Anime.order(:id), terms }

  let(:ghibli) { create :studio, id: 83 }
  let(:ghibli_clone) { create :studio, id: 48 }
  let(:shaft) { create :studio }

  let!(:anime_1) { create :anime, studio_ids: [ghibli.id, shaft.id] }
  let!(:anime_2) { create :anime, studio_ids: [ghibli.id] }
  let!(:anime_3) { create :anime, studio_ids: [ghibli_clone.id] }
  let!(:anime_4) { create :anime }
  let!(:anime_5) { create :anime, studio_ids: [shaft.id] }

  context 'positive' do
    context 'ghibli' do
      let(:terms) { ghibli.to_param }
      it { is_expected.to eq [anime_1, anime_2, anime_3] }
    end

    context 'ghibli_clone' do
      let(:terms) { ghibli_clone.to_param }
      it { is_expected.to eq [anime_1, anime_2, anime_3] }
    end

    context 'shaft' do
      let(:terms) { shaft.to_param }
      it { is_expected.to eq [anime_1, anime_5] }
    end

    context 'ghibli, shaft' do
      let(:terms) { "#{ghibli.to_param},#{shaft.to_param}" }
      it { is_expected.to eq [anime_1] }
    end
  end

  context 'negative' do
    context '!ghibli' do
      let(:terms) { "!#{ghibli.to_param}" }
      it { is_expected.to eq [anime_4, anime_5] }
    end

    context '!shaft' do
      let(:terms) { "!#{shaft.to_param}" }
      it { is_expected.to eq [anime_2, anime_3, anime_4] }
    end

    context '!ghibli,!shaft' do
      let(:terms) { "!#{shaft.to_param},!#{ghibli.to_param}" }
      it { is_expected.to eq [anime_4] }
    end
  end

  context 'both' do
    context 'ghibli,!shaft' do
      let(:terms) { "#{ghibli.to_param},!#{shaft.to_param}" }
      it { is_expected.to eq [anime_2, anime_3] }
    end

    context '!ghibli,shaft' do
      let(:terms) { "!#{ghibli.to_param},#{shaft.to_param}" }
      it { is_expected.to eq [anime_5] }
    end
  end
end
