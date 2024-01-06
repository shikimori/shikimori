describe MalParsers::ScheduleMissingPersonRoles do
  let(:worker) { MalParsers::ScheduleMissingPersonRoles.new }

  let!(:character) { create :character }
  let!(:person_role_1) { create :person_role, character_id: character.id }
  let!(:person_role_2) { create :person_role, character_id: 123456 }
  let!(:person_role_3) { create :person_role, character_id: 123456 }
  let!(:person_role_4) { create :person_role, character_id: 456789 }
  let!(:person_role_5) { create :person_role, person_id: 789012 }

  before { allow(MalParsers::FetchEntry).to receive :perform_async }
  subject! { worker.perform 'character' }

  it do
    is_expected.to eq [123456, 456789]
    expect(MalParsers::FetchEntry)
      .to have_received(:perform_async)
      .with(123456, 'character')
      .ordered
    expect(MalParsers::FetchEntry)
      .to have_received(:perform_async)
      .with(456789, 'character')
      .ordered
  end
end
