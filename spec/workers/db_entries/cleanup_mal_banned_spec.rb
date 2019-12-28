describe DbEntries::CleanupMalBanned do
  let!(:banned_role) { create :person_role, anime_id: 114, character_id: 1009 }

  let!(:role_1) { create :person_role, anime_id: 114, character_id: 1010 }
  let!(:role_2) { create :person_role, manga_id: 114, character_id: 1009 }
  let!(:role_3) { create :person_role, anime_id: 114, person_id: 1009 }
  let!(:role_4) { create :person_role, manga_id: 114, person_id: 1009 }

  let!(:banned_anime) { create :anime, id: 35614 }
  let!(:anime) { create :anime }

  let!(:banned_manga) { create :manga, id: 59267 }
  let!(:manga) { create :manga }

  let!(:banned_ranobe) { create :ranobe, id: 88888888 }
  let!(:ranobe) { create :ranobe }

  let!(:banned_character) { create :character, id: 7746 }
  let!(:character) { create :character }

  let!(:banned_person) { create :person, id: 32789 }
  let!(:person) { create :person }

  subject! { described_class.new.perform }

  it do
    expect { banned_role.reload }.to raise_error ActiveRecord::RecordNotFound

    expect(role_1.reload).to be_persisted
    expect(role_2.reload).to be_persisted
    expect(role_3.reload).to be_persisted
    expect(role_4.reload).to be_persisted

    expect { banned_anime.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(anime.reload).to be_persisted

    expect { banned_manga.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(manga.reload).to be_persisted

    expect { banned_ranobe.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(ranobe.reload).to be_persisted

    expect { banned_character.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(character.reload).to be_persisted

    expect { banned_person.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(person.reload).to be_persisted
  end
end
