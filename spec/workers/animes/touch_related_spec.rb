describe Animes::TouchRelated do
  include_context :timecop

  let(:worker) { Animes::TouchRelated.new }

  let!(:anime) { create :anime }
  let!(:anime_related) { create :anime }
  let!(:related_anime_1) { create :related_anime, source: anime, anime: anime_related }
  let!(:related_anime_2) { create :related_anime, source: anime, manga: manga_related }
  let!(:anime_similar) { create :anime }

  let!(:manga) { create :manga }
  let!(:manga_related) { create :manga }
  let!(:related_manga_1) { create :related_manga, source: manga, anime: anime_related }
  let!(:related_manga_2) { create :related_manga, source: manga, manga: manga_related }
  let!(:manga_similar) { create :manga }

  let!(:character) { create :character }

  let(:person) { create :person }

  before do
    anime.similar_animes << anime_similar
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
