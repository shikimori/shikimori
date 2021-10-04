describe DbImport::Refresh do
  let(:service) { described_class.new klass, ids, refresh_interval }
  let(:klass) { Anime }
  let(:refresh_interval) { 1.day }

  let(:expired_time) { refresh_interval.ago - 1.minute }
  let(:not_expired_time) { refresh_interval.ago + 1.minute }

  describe 'entry' do
    let!(:anime_1) { create :anime, imported_at: expired_time }
    let!(:anime_2) { create :anime, imported_at: not_expired_time }
    let(:ids) { [anime_1.id, anime_2.id] }

    subject! { service.call }

    it do
      expect(anime_1.reload.imported_at).to eq nil
      expect(anime_2.reload.imported_at).to_not eq nil
    end
  end

  describe 'characters' do
    let!(:anime) { create :anime, imported_at: expired_time }
    let(:ids) { [anime.id] }

    let!(:character_1) { create :character, imported_at: expired_time }
    let!(:character_2) { create :character, imported_at: not_expired_time }

    let!(:role_1) { create :person_role, anime: anime, character: character_1 }
    let!(:role_2) { create :person_role, anime: anime, character: character_2 }

    subject! { service.call }

    it do
      expect(anime.reload.imported_at).to eq nil
      expect(character_1.reload.imported_at).to eq nil
      expect(character_2.reload.imported_at).to_not eq nil
    end
  end

  describe 'people' do
    let!(:anime) { create :anime, imported_at: expired_time }
    let(:ids) { [anime.id] }

    let!(:person_1) { create :person, imported_at: expired_time }
    let!(:person_2) { create :person, imported_at: not_expired_time }

    let!(:role_1) { create :person_role, anime: anime, person: person_1 }
    let!(:role_2) { create :person_role, anime: anime, person: person_2 }

    subject! { service.call }

    it do
      expect(anime.reload.imported_at).to eq nil
      expect(person_1.reload.imported_at).to eq nil
      expect(person_2.reload.imported_at).to_not eq nil
    end
  end
end
