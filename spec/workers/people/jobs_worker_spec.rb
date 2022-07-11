describe People::JobsWorker do
  let!(:person_1) { create :person }
  let!(:person_2) { create :person }
  let!(:person_3) { create :person }

  let!(:person_role_1_1) { create :person_role, person: person_1, roles: ['Director'] }
  let!(:person_role_1_2) { create :person_role, person: person_1, roles: [Person::MANGAKA_ROLES.sample] }
  let!(:person_role_1_3) { create :person_role, person: person_1, roles: [Person::SEYU_ROLES.sample] }
  let!(:person_role_2_1) { create :person_role, person: person_2, roles: ['Director'] }

  subject! { described_class.new.perform }

  it do
    expect(person_1.reload).to have_attributes(
      is_producer: true,
      is_mangaka: true,
      is_seyu: true
    )
    expect(person_2.reload).to have_attributes(
      is_producer: true,
      is_mangaka: false,
      is_seyu: false
    )
    expect(person_3.reload).to have_attributes(
      is_producer: false,
      is_mangaka: false,
      is_seyu: false
    )
  end
end
