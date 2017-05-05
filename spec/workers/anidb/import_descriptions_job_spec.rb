# frozen_string_literal: true

describe Anidb::ImportDescriptionsJob do
  subject(:perform) { job.perform }
  let(:job) { described_class.new }

  include_context :timecop

  let(:anime_1) { create :anime }
  let(:anime_2) { create :anime }
  let(:manga) { create :manga }

  let!(:anime_external_link_1) do
    create :external_link,
      entry: anime_1,
      url: 'https://myanimelist.net/anime/889'
  end
  let!(:anime_external_link_2) do
    create :external_link,
      entry: anime_2,
      url: 'https://myanimelist.net/anime/890'
  end
  let!(:manga_external_link) do
    create :external_link,
      entry: manga,
      url: 'https://myanimelist.net/manga/889'
  end

  let(:parsed_anime_description_en_1) { 'cool anime[source]ANN[/source]' }
  let(:parsed_anime_description_en_2) { 'best anime[source]ANN[/source]' }
  let(:parsed_manga_description_en) { 'cool manga' }

  let(:processed_anime_description_en_1) do
    'cool anime[source]animenewsnetwork.com[/source]'
  end
  let(:processed_anime_description_en_2) do
    'best anime[source]animenewsnetwork.com[/source]'
  end
  let(:processed_manga_description_en) do
    'cool manga[source]https://myanimelist.net/manga/889[/source]'
  end

  before do
    allow(Anidb::ImportDescriptionsQuery)
      .to receive(:for_import)
      .with(Anime)
      .and_return(Anime.all)
    allow(Anidb::ImportDescriptionsQuery)
      .to receive(:for_import)
      .with(Manga)
      .and_return(Manga.all)

    allow(Anidb::ParseDescription)
      .to receive(:call)
      .with(anime_external_link_1.url)
      .and_return(parsed_anime_description_en_1)
    allow(Anidb::ParseDescription)
      .to receive(:call)
      .with(anime_external_link_2.url)
      .and_return(parsed_anime_description_en_2)
    allow(Anidb::ParseDescription)
      .to receive(:call)
      .with(manga_external_link.url)
      .and_return(parsed_manga_description_en)

    allow(Anidb::ProcessDescription)
      .to receive(:call)
      .with(parsed_anime_description_en_1, anime_external_link_1.url)
      .and_return(processed_anime_description_en_1)
    allow(Anidb::ProcessDescription)
      .to receive(:call)
      .with(parsed_anime_description_en_2, anime_external_link_2.url)
      .and_return(processed_anime_description_en_2)
    allow(Anidb::ProcessDescription)
      .to receive(:call)
      .with(parsed_manga_description_en, manga_external_link.url)
      .and_return(processed_manga_description_en)
  end

  context 'with valid exernal link url' do
    before { perform }

    it do
      expect(Anidb::ParseDescription)
        .to have_received(:call)
        .with(anime_external_link_1.url)
        .once
      expect(Anidb::ParseDescription)
        .to have_received(:call)
        .with(anime_external_link_2.url)
        .once
      expect(Anidb::ParseDescription)
        .to have_received(:call)
        .with(manga_external_link.url)
        .once

      expect(Anidb::ProcessDescription)
        .to have_received(:call)
        .with(parsed_anime_description_en_1, anime_external_link_1.url)
        .once
      expect(Anidb::ProcessDescription)
        .to have_received(:call)
        .with(parsed_anime_description_en_2, anime_external_link_2.url)
        .once
      expect(Anidb::ProcessDescription)
        .to have_received(:call)
        .with(parsed_manga_description_en, manga_external_link.url)
        .once

      expect(anime_1.reload.description_en).to eq processed_anime_description_en_1
      expect(anime_2.reload.description_en).to eq processed_anime_description_en_2
      expect(manga.reload.description_en).to eq processed_manga_description_en

      expect(anime_external_link_1.reload.imported_at)
        .to be_within(0.1).of(Time.zone.now)
      expect(anime_external_link_2.reload.imported_at)
        .to be_within(0.1).of(Time.zone.now)
      expect(manga_external_link.reload.imported_at)
        .to be_within(0.1).of(Time.zone.now)
    end
  end

  context 'with invalid external link url' do
    let!(:anime_external_link_2) do
      create :external_link,
        entry: anime_2,
        url: 'https://myanimelist.net/animefoo/890'
    end

    before do
      allow(Anidb::ParseDescription)
        .to receive(:call)
        .with(anime_external_link_2.url)
        .and_raise NotFound, anime_external_link_2.url
    end

    before { perform }

    it do
      expect(Anidb::ParseDescription)
        .to have_received(:call)
        .with(anime_external_link_1.url)
        .once
      expect(Anidb::ParseDescription)
        .to have_received(:call)
        .with(anime_external_link_2.url)
        .once
      expect(Anidb::ParseDescription)
        .to have_received(:call)
        .with(manga_external_link.url)
        .once

      expect(Anidb::ProcessDescription)
        .to have_received(:call)
        .with(parsed_anime_description_en_1, anime_external_link_1.url)
        .once
      expect(Anidb::ProcessDescription)
        .not_to have_received(:call)
        .with(parsed_anime_description_en_2, anime_external_link_2.url)
      expect(Anidb::ProcessDescription)
        .to have_received(:call)
        .with(parsed_manga_description_en, manga_external_link.url)
        .once

      expect(anime_1.reload.description_en).to eq processed_anime_description_en_1
      expect(anime_2.reload.description_en).to be_empty
      expect(manga.reload.description_en).to eq processed_manga_description_en

      expect(anime_1.reload.anidb_external_link).to be_present
      expect(anime_2.reload.anidb_external_link).to be_nil
      expect(manga.reload.anidb_external_link).to be_present

      expect(anime_external_link_1.reload.imported_at)
        .to be_within(0.1).of(Time.zone.now)
      expect(manga_external_link.reload.imported_at)
        .to be_within(0.1).of(Time.zone.now)
    end
  end
end
