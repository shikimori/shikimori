describe Animes::TouchRelated do
  include_context :timecop

  let(:worker) { Animes::TouchRelated.new }

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
  subject! { worker.perform db_entry.id, db_entry.class.base_class.name }

  context 'anime' do
    let(:db_entry) { anime }

    it do
      expect(anime.reload.updated_at.to_i).to eq 1.day.ago.to_i
      expect(anime_related.reload.updated_at.to_i).to eq Time.zone.now.to_i
      expect(anime_similar.reload.updated_at.to_i).to eq Time.zone.now.to_i

      expect(manga.reload.updated_at.to_i).to eq 1.day.ago.to_i
      expect(manga_related.reload.updated_at.to_i).to eq Time.zone.now.to_i
      expect(manga_similar.reload.updated_at.to_i).to eq 1.day.ago.to_i

      expect(character.reload.updated_at.to_i).to eq Time.zone.now.to_i

      expect(person.reload.updated_at.to_i).to eq Time.zone.now.to_i
    end
  end

  context 'manga' do
    let(:db_entry) { manga }

    it do
      expect(anime.reload.updated_at.to_i).to eq 1.day.ago.to_i
      expect(anime_related.reload.updated_at.to_i).to eq Time.zone.now.to_i
      expect(anime_similar.reload.updated_at.to_i).to eq 1.day.ago.to_i

      expect(manga.reload.updated_at.to_i).to eq 1.day.ago.to_i
      expect(manga_related.reload.updated_at.to_i).to eq Time.zone.now.to_i
      expect(manga_similar.reload.updated_at.to_i).to eq Time.zone.now.to_i

      expect(character.reload.updated_at.to_i).to eq Time.zone.now.to_i

      expect(person.reload.updated_at.to_i).to eq Time.zone.now.to_i
    end
  end

  context 'character' do
    let(:db_entry) { character }
    it do
      expect(anime.reload.updated_at.to_i).to eq Time.zone.now.to_i
      expect(anime_related.reload.updated_at.to_i).to eq 1.day.ago.to_i
      expect(anime_similar.reload.updated_at.to_i).to eq 1.day.ago.to_i

      expect(manga.reload.updated_at.to_i).to eq Time.zone.now.to_i
      expect(manga_related.reload.updated_at.to_i).to eq 1.day.ago.to_i
      expect(manga_similar.reload.updated_at.to_i).to eq 1.day.ago.to_i

      expect(character.reload.updated_at.to_i).to eq 1.day.ago.to_i

      expect(person.reload.updated_at.to_i).to eq Time.zone.now.to_i
    end
  end

  context 'person' do
    let(:db_entry) { person }

    it do
      expect(anime.reload.updated_at.to_i).to eq Time.zone.now.to_i
      expect(anime_related.reload.updated_at.to_i).to eq 1.day.ago.to_i
      expect(anime_similar.reload.updated_at.to_i).to eq 1.day.ago.to_i

      expect(manga.reload.updated_at.to_i).to eq Time.zone.now.to_i
      expect(manga_related.reload.updated_at.to_i).to eq 1.day.ago.to_i
      expect(manga_similar.reload.updated_at.to_i).to eq 1.day.ago.to_i

      expect(character.reload.updated_at.to_i).to eq Time.zone.now.to_i

      expect(person.reload.updated_at.to_i).to eq 1.day.ago.to_i
    end
  end
end
