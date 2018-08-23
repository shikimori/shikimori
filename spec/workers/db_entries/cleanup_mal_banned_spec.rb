describe DbEntries::CleanupMalBanned do
  let!(:banned_role) { create :person_role, anime_id: 114, character_id: 1009 }
  let!(:role_1) { create :person_role, anime_id: 114, character_id: 1010 }
  let!(:role_2) { create :person_role, manga_id: 114, character_id: 1009 }
  let!(:role_3) { create :person_role, anime_id: 114, person_id: 1009 }
  let!(:role_4) { create :person_role, manga_id: 114, person_id: 1009 }

  subject! { described_class.new.perform }

  it do
    expect { banned_role.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(role_1.reload).to be_persisted
    expect(role_2.reload).to be_persisted
    expect(role_3.reload).to be_persisted
    expect(role_4.reload).to be_persisted
  end
end
