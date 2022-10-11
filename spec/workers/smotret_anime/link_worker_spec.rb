describe SmotretAnime::LinkWorker, :vcr do
  include_context :timecop

  let!(:external_link_1) do
    create :external_link, :anime_news_network, :shikimori,
      entry: anime,
      url: 'https://www.animenewsnetwork.com/encyclopedia/anime.php?id=21237'
  end
  let!(:external_link_2) do
    create :external_link, :world_art,
      source: 'smotret_anime',
      entry: anime,
      url: 'http://www.world-art.ru/animation/animation.php?id=9778'
  end
  let!(:external_link_3) do
    create :external_link, :kage_project, :shikimori,
      entry: anime,
      url: 'http://fansubs.ru/base.php?id=5387'
  end
  let!(:external_link_4) { nil }

  subject! { described_class.new.perform anime.id }

  let(:anime) { create :anime, mal_id: mal_id, aired_on: aired_on, status: status }
  let(:aired_on) { 1.week.from_now }
  let(:status) { :anons }

  context 'no mal_id' do
    let(:mal_id) { nil }
    it { expect(anime.all_external_links).to have(3).items }
  end

  context 'matched mal_id' do
    let(:mal_id) { 38080 }
    it do
      expect(external_link_1.reload).to be_persisted
      expect { external_link_2.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(external_link_3.reload).to be_persisted

      expect(anime.all_external_links).to have(6).items
      expect(anime.all_external_links[0]).to eq external_link_1
      expect(anime.all_external_links[1]).to eq external_link_3
      expect(anime.all_external_links[2]).to have_attributes(
        kind: 'smotret_anime',
        url: 'https://smotret-anime.online/catalog/19351',
        source: 'smotret_anime'
      )
      expect(anime.all_external_links[2].imported_at).to be_within(0.1).of Time.zone.now
      expect(anime.all_external_links[3]).to have_attributes(
        kind: 'world_art',
        url: 'http://www.world-art.ru/animation/animation.php?id=9778',
        source: 'smotret_anime'
      )
      expect(anime.all_external_links[3].imported_at).to be_within(0.1).of Time.zone.now
      expect(anime.all_external_links[4]).to have_attributes(
        kind: 'wikipedia',
        url: 'https://en.wikipedia.org/wiki/Kono_Oto_Tomare!',
        source: 'smotret_anime'
      )
      expect(anime.all_external_links[4].imported_at).to be_within(0.1).of Time.zone.now
    end

    context 'disabled smotret_anime parsing' do
      let!(:external_link_4) do
        create :external_link,
          source: :smotret_anime,
          kind: :smotret_anime,
          entry: anime,
          url: Animes::SmotretAnimeId::NO_ID
      end
      it { expect(anime.all_external_links).to have(4).items }
    end
  end

  context 'not matched mal_id' do
    let(:mal_id) { 999_999 }

    context 'ongoing/released && aired_on < 1.month.ago' do
      let(:aired_on) { described_class::GIVE_UP_INTERVAL.ago - 1.day }
      let(:status) { %i[ongoing released].sample }

      it do
        expect(anime.all_external_links).to have(4).items
        expect(anime.all_external_links[3]).to have_attributes(
          source: 'smotret_anime',
          kind: 'smotret_anime',
          url: Animes::SmotretAnimeId::NO_ID
        )
        expect(anime.all_external_links[3].imported_at).to be_within(0.1).of Time.zone.now
      end
    end

    context 'not ongoing/released || aired_on < 1.month.ago' do
      let(:status) { %i[ongoing released anons].sample }
      let(:aired_on) do
        status != :ongoing && status != :released ?
          described_class::GIVE_UP_INTERVAL.ago - 1.day :
          described_class::GIVE_UP_INTERVAL.ago + 1.day
      end
      it { expect(anime.all_external_links).to have(3).items }
    end

    context 'hentai365 fallback' do
      let(:mal_id) { 51_722 }
      it do
        expect(anime.all_external_links).to have(4).items
        expect(anime.all_external_links[2]).to have_attributes(
          kind: 'smotret_anime',
          url: 'https://smotret-anime.online/catalog/26152',
          source: 'smotret_anime'
        )
      end
    end
  end
end
