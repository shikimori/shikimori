describe DbImport::PersonRoles do
  include_context :timecop

  let(:target) { create :anime, id: 114 }
  let(:characters) do
    [{
      id: character.id,
      roles: %w[Main]
    }, {
      id: 123_456,
      roles: %w[Supporting]
    }, {
      id: 1009, # banned mal id
      roles: %w[Supporting]
    }]
  end
  let(:staff) do
    [{
      id: person.id,
      roles: %w[Director]
    }, {
      id: 123_458,
      roles: %w[Producer]
    }]
  end
  let!(:person_role) { nil }
  let(:person_roles) { target.person_roles.order :id }

  let!(:character) { create :character, imported_at: imported_at }
  let!(:person) { create :person, imported_at: imported_at }
  let(:imported_at) { described_class::REIMPORT_INTERVAL.ago + 1.day }

  before { allow(MalParsers::FetchEntry).to receive :perform_in }
  subject! { described_class.call target, characters, staff }

  it do
    expect(person_roles).to have(4).items
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
      character_id: characters[1][:id],
      person_id: nil,
      roles: characters[1][:roles]
    )
    expect(person_roles[2]).to have_attributes(
      anime_id: target.id,
      manga_id: nil,
      character_id: nil,
      person_id: person.id,
      roles: staff[0][:roles]
    )
    expect(person_roles[3]).to have_attributes(
      anime_id: target.id,
      manga_id: nil,
      character_id: nil,
      person_id: staff[1][:id],
      roles: staff[1][:roles]
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
      expect(person_roles).to have(4).items
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
      expect(person_roles).to have(5).items
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

  describe 'schedules imports' do
    it do
      expect(MalParsers::FetchEntry).to have_received(:perform_in).twice
      expect(MalParsers::FetchEntry)
        .to have_received(:perform_in)
        .with 3.seconds, characters[1][:id], 'character'
      expect(MalParsers::FetchEntry)
        .to have_received(:perform_in)
        .with 3.seconds, staff[1][:id], 'person'
    end

    context 'not fresh entries' do
      let(:imported_at) { described_class::REIMPORT_INTERVAL.ago - 1.day }
      it do
        expect(MalParsers::FetchEntry).to have_received(:perform_in).exactly(4).times
      end
    end
  end
end
