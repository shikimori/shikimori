# frozen_string_literal: true

describe Anidb::ImportDescriptionsQuery do
  let(:query) { described_class }
  let(:relation) { Anime }

  let!(:anime_1) do
    create :anime,
      description_en: 'foo[source]http://myanimelist.net/anime/889[/source]'
  end
  let!(:anime_2) do
    create :anime,
      description_en: 'foo[source]http://myanimelist.net/anime/890[/source]'
  end

  let!(:external_link_1) do
    create :external_link, :anime_db, entry: anime_1, imported_at: nil
  end
  let!(:external_link_2) do
    create :external_link, :anime_db, entry: anime_2, imported_at: nil
  end

  describe '.for_import' do
    subject { query.for_import relation }

    context 'valid animes' do
      it { is_expected.to eq [anime_1, anime_2] }
    end

    context 'with not mal description' do
      let(:anime_1) do
        create :anime,
          description_en: 'foo[source]animenewsnetwork.com[/source]'
      end
      it { is_expected.to eq [anime_2] }
    end

    context 'with empty description' do
      let(:anime_1) { create :anime, description_en: '' }
      it { is_expected.to eq [anime_1, anime_2] }
    end

    context 'with nil description' do
      let(:anime_1) { create :anime, description_en: nil }
      it { is_expected.to eq [anime_1, anime_2] }
    end

    context 'without external link' do
      let!(:external_link_2) { nil }
      it { is_expected.to eq [anime_1] }
    end

    context 'with already imported external link' do
      let!(:external_link_2) do
        create :external_link,
          :anime_db,
          entry: anime_2,
          imported_at: Time.zone.now
      end
      it { is_expected.to eq [anime_1] }
    end

    context 'with wikipedia external link' do
      let!(:external_link_2) do
        create :external_link, :wikipedia, entry: anime_2, imported_at: nil
      end
      it { is_expected.to eq [anime_1] }
    end
  end
end
