describe MalParsers::FetchEntryAuthorized do
  # TODO: move :vcr to MalParsers::AnimeAuthorized and
  #       stub call to MalParsers::AnimeAuthorized here
  describe '#perform', :vcr do
    include_context :timecop

    let!(:genre_drama) { create :genre, :anime, name: 'Drama', mal_id: 8 }
    let!(:genre_school) { create :genre, :anime, name: 'School', mal_id: 23 }
    let!(:genre_shounen) { create :genre, :anime, name: 'Shounen', mal_id: 27 }

    subject!(:call) { described_class.new.perform anime_id, 'Anime' }

    let(:anime_id) { 28_851 }
    let(:anime) { Anime.find(anime_id) }

    it do
      anime.reload
      expect(anime.all_external_links).to have(4).items
      expect(anime.authorized_imported_at).to be_within(0.1).of(Time.zone.now)
    end
  end
end
