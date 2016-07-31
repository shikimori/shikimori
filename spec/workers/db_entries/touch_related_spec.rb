describe DbEntries::TouchRelated do
  before { Timecop.freeze }
  after { Timecop.return }

  let(:worker) { DbEntries::TouchRelated.new }

  describe '#perform' do
    let!(:anime) { create :anime }
    let!(:anime_related) { create :anime }
    let!(:anime_similar) { create :anime }

    let!(:manga) { create :manga }
    let!(:manga_related) { create :manga }
    let!(:manga_similar) { create :manga }

    let!(:character) { create :character }

    let(:person) { create :person }

    before do
      anime.related_animes << anime_related
      anime.related_mangas << manga_related
      anime.similar_animes << anime_similar

      manga.related_animes << anime_related
      manga.related_mangas << manga_related
      manga.similar_mangas << manga_similar

      anime.characters << character
      anime.people << person

      manga.characters << character
      manga.people << person

      character.people << person
      person.characters << character

      Anime.update_all updated_at: 1.day.ago
      Manga.update_all updated_at: 1.day.ago
      Character.update_all updated_at: 1.day.ago
      Person.update_all updated_at: 1.day.ago
    end
    subject! { worker.perform db_entry.reload }

    context 'anime' do
      let(:db_entry) { anime }

      it do
        expect(anime.reload.updated_at).to eq 1.day.ago
        expect(anime_related.reload.updated_at).to eq Time.zone.now
        expect(anime_similar.reload.updated_at).to eq Time.zone.now

        expect(manga.reload.updated_at).to eq 1.day.ago
        expect(manga_related.reload.updated_at).to eq Time.zone.now
        expect(manga_similar.reload.updated_at).to eq 1.day.ago

        expect(character.reload.updated_at).to eq Time.zone.now

        expect(person.reload.updated_at).to eq Time.zone.now
      end
    end

    context 'manga' do
      let(:db_entry) { manga }

      it do
        expect(anime.reload.updated_at).to eq 1.day.ago
        expect(anime_related.reload.updated_at).to eq Time.zone.now
        expect(anime_similar.reload.updated_at).to eq 1.day.ago

        expect(manga.reload.updated_at).to eq 1.day.ago
        expect(manga_related.reload.updated_at).to eq Time.zone.now
        expect(manga_similar.reload.updated_at).to eq Time.zone.now

        expect(character.reload.updated_at).to eq Time.zone.now

        expect(person.reload.updated_at).to eq Time.zone.now
      end
    end

    context 'character' do
      let(:db_entry) { character }
      it do
        expect(anime.reload.updated_at).to eq Time.zone.now
        expect(anime_related.reload.updated_at).to eq 1.day.ago
        expect(anime_similar.reload.updated_at).to eq 1.day.ago

        expect(manga.reload.updated_at).to eq Time.zone.now
        expect(manga_related.reload.updated_at).to eq 1.day.ago
        expect(manga_similar.reload.updated_at).to eq 1.day.ago

        expect(character.reload.updated_at).to eq 1.day.ago

        expect(person.reload.updated_at).to eq Time.zone.now
      end
    end

    context 'person' do
      let(:db_entry) { person }

      it do
        expect(anime.reload.updated_at).to eq Time.zone.now
        expect(anime_related.reload.updated_at).to eq 1.day.ago
        expect(anime_similar.reload.updated_at).to eq 1.day.ago

        expect(manga.reload.updated_at).to eq Time.zone.now
        expect(manga_related.reload.updated_at).to eq 1.day.ago
        expect(manga_similar.reload.updated_at).to eq 1.day.ago

        expect(character.reload.updated_at).to eq Time.zone.now

        expect(person.reload.updated_at).to eq 1.day.ago
      end
    end
  end
end
