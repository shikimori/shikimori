# frozen_string_literal: true

describe DbEntries::WithDescriptionQuery do
  let(:query) { described_class }
  let(:relation) { Anime.all }

  describe '.with_description_ru_source' do
    subject { query.with_description_ru_source relation }

    let!(:anime_1) { create :anime, description_ru: 'foo[source]bar[/source]' }
    let!(:anime_2) { create :anime, description_ru: 'foo[source][/source]' }

    it { is_expected.to eq [anime_1] }
  end
end
