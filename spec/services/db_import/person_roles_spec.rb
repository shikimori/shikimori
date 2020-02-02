describe DbImport::PersonRoles do
  include_context :timecop

  let(:service) { DbImport::PersonRoles.new target, characters, staff }
  let(:target) { create :anime, id: 114 }
  let(:characters) do
    [{
      id: character.id,
      roles: %w[Main]
    }, {
      id: 145176,
      roles: %w[Supporting]
    }, {
      id: 1009,
      roles: %w[Supporting]
    }]
  end
  let(:staff) do
    [{
      id: person.id,
      roles: %w[Director]
    }]
  end
  let!(:person_role) {}
  let(:person_roles) { target.person_roles.order :id }

  let!(:character) { build_stubbed :character }
  let!(:person) { build_stubbed :character }

  subject! { service.call }

  it do
    expect(person_roles).to have(3).items
    expect(person_roles[0]).to have_attributes(
      anime_id: target.id,
      manga_id: nil,
      character_id: character.id,
      person_id: nil,
      roles: %w[Main]
    )
    expect(person_roles[1]).to have_attributes(
      anime_id: target.id,
      manga_id: nil,
      character_id: 145_176,
      person_id: nil,
      roles: %w[Supporting]
    )
    expect(person_roles[2]).to have_attributes(
      anime_id: target.id,
      manga_id: nil,
      character_id: nil,
      person_id: person.id,
      roles: %w[Director]
    )
  end

  describe 'replaces same roles' do
    let!(:person_role) do
      create :person_role,
        anime_id: target.id,
        character_id: character.id
    end
    it do
      expect { person_role.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(person_roles).to have(3).items
    end
  end

  describe 'does not replace roles for other types' do
    let!(:person_role) do
      create :person_role,
        anime_id: target.id,
        manga_id: 28_735
    end

    it do
      expect(person_role.reload).to be_persisted
      expect(person_roles).to have(4).items
    end
  end

  describe 'touches related' do
    let!(:character) { create :character, updated_at: 10.minutes.ago }
    let!(:person) { create :person, updated_at: 10.minutes.ago }

    it do
      expect(character.reload.updated_at).to be_within(0.1).of Time.zone.now
      expect(person.reload.updated_at).to be_within(0.1).of Time.zone.now
    end
  end
end
