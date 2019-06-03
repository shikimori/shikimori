describe Animes::LinkSmotretAnime, :vcr do
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

  subject! { described_class.new.perform anime.id }

  let(:anime) { create :anime, mal_id: mal_id }
  let(:mal_id) { 38080 }

  context 'no mal_id' do
    let(:mal_id) { nil }
    it { expect(anime.all_external_links).to have(3).items }
  end

  it do
    expect(external_link_1.reload).to be_persisted
    expect { external_link_2.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(external_link_3.reload).to be_persisted

    expect(anime.all_external_links).to have(6).items
    expect(anime.all_external_links[0]).to eq external_link_1
    expect(anime.all_external_links[1]).to eq external_link_3
    expect(anime.all_external_links[2]).to have_attributes(
      kind: 'smotret_anime',
      url: 'https://smotretanime.ru/catalog/19351',
      source: 'smotret_anime'
    )
    expect(anime.all_external_links[3]).to have_attributes(
      kind: 'world_art',
      url: 'http://www.world-art.ru/animation/animation.php?id=9778',
      source: 'smotret_anime'
    )
    expect(anime.all_external_links[4]).to have_attributes(
      kind: 'wikipedia',
      url: 'https://en.wikipedia.org/wiki/Kono_Oto_Tomare!',
      source: 'smotret_anime'
    )
    expect(anime.all_external_links[5]).to have_attributes(
      kind: 'wikipedia',
      url: 'https://en.wikipedia.org/wiki/Kono_Oto_Tomare!_Sounds_of_Life',
      source: 'smotret_anime'
    )
  end
end
