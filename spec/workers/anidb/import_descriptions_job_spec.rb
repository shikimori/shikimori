# frozen_string_literal: true

describe Anidb::ImportDescriptionsJob do
  let(:job) { Anidb::ImportDescriptionsJob.new }

  include_context :timecop

  let(:anime) { create :anime }
  let!(:anime_external_link) do
    create :external_link,
      entry: anime,
      url: 'https://myanimelist.net/anime/889'
  end
  let(:parsed_anime_description_en) { 'cool anime[source]ANN[/source]' }
  let(:processed_anime_description_en) do
    'cool anime[source]animenewsnetwork.com[/source]'
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
      .with(anime_external_link.url)
      .and_return(parsed_anime_description_en)
    allow(Anidb::ProcessDescription)
      .to receive(:call)
      .with(parsed_anime_description_en, anime_external_link.url)
      .and_return(processed_anime_description_en)
  end

  context 'with valid exernal link url' do
    let(:anime_2) { create :anime }
    let!(:anime_external_link_2) do
      create :external_link,
        entry: anime_2,
        url: 'https://myanimelist.net/anime/890'
    end
    let(:parsed_anime_description_en_2) { 'best anime[source]ANN[/source]' }
    let(:processed_anime_description_en_2) do
      'best anime[source]animenewsnetwork.com[/source]'
    end

    let(:manga) { create :manga }
    let!(:manga_external_link) do
      create :external_link,
        entry: manga,
        url: 'https://myanimelist.net/manga/889'
    end
    let(:parsed_manga_description_en) { 'cool manga' }
    let(:processed_manga_description_en) do
      'cool manga[source]https://myanimelist.net/manga/889[/source]'
    end

    before do
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
        .with(parsed_anime_description_en_2, anime_external_link_2.url)
        .and_return(processed_anime_description_en_2)
      allow(Anidb::ProcessDescription)
        .to receive(:call)
        .with(parsed_manga_description_en, manga_external_link.url)
        .and_return(processed_manga_description_en)
    end

    subject! { job.perform }

    it do
      expect(Anidb::ParseDescription)
        .to have_received(:call)
        .with(anime_external_link.url)
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
        .with(parsed_anime_description_en, anime_external_link.url)
        .once
      expect(Anidb::ProcessDescription)
        .to have_received(:call)
        .with(parsed_anime_description_en_2, anime_external_link_2.url)
        .once
      expect(Anidb::ProcessDescription)
        .to have_received(:call)
        .with(parsed_manga_description_en, manga_external_link.url)
        .once

      expect(anime.reload.description_en).to eq processed_anime_description_en
      expect(anime_2.reload.description_en).to eq processed_anime_description_en_2
      expect(manga.reload.description_en).to eq processed_manga_description_en

      expect(anime_external_link.reload.imported_at)
        .to be_within(0.1).of(Time.zone.now)
      expect(anime_external_link_2.reload.imported_at)
        .to be_within(0.1).of(Time.zone.now)
      expect(manga_external_link.reload.imported_at)
        .to be_within(0.1).of(Time.zone.now)
    end
  end

  context 'with invalid external link url' do
    context InvalidIdError do
      before do
        allow(Anidb::ParseDescription)
          .to receive(:call)
          .with(anime_external_link.url)
          .and_raise InvalidIdError, anime_external_link.url
      end

      subject! { job.perform }

      it do
        expect(anime.reload.description_en).to be_empty
        expect(anime.reload.anidb_external_link).to be_nil

        expect { anime_external_link.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
