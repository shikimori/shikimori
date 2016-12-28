describe Import::PersonRoles do
  let(:service) { Import::PersonRoles.new target, person_roles, id_key }
  let(:target) { create :anime }
  let(:person_roles) do
    [{
      id: 33_365,
      role: 'Director'
    }, {
      id: 30_337,
      role: 'Sound Director'
    }]
  end
  let!(:person_role) do
    create :person_role,
      anime_id: target.id,
      character_id: 28_735
  end
  let(:id_key) { :character_id }

  subject! { service.call }

  it do
    expect { person_role.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(target.person_roles).to have(2).items
    expect(target.person_roles.first).to have_attributes(
      anime_id: target.id,
      manga_id: nil,
      character_id: 33_365,
      person_id: nil,
      role: 'Director'
    )
    expect(target.person_roles.second).to have_attributes(
      anime_id: target.id,
      manga_id: nil,
      character_id: 30_337,
      person_id: nil,
      role: 'Sound Director'
    )
  end
end
