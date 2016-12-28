describe Import::PersonRoles do
  let(:service) { Import::PersonRoles.new target, characters, staff }
  let(:target) { create :anime }
  let(:characters) do
    [{
      id: 143_628,
      role: 'Main'
    }, {
      id: 145_176,
      role: 'Supporting'
    }]
  end
  let(:staff) do
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

  let(:person_roles) { target.person_roles.order :id }
  subject! { service.call }

  it do
    expect { person_role.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(person_roles).to have(4).items
    expect(person_roles[0]).to have_attributes(
      anime_id: target.id,
      manga_id: nil,
      character_id: 143_628,
      person_id: nil,
      role: 'Main'
    )
    expect(person_roles[1]).to have_attributes(
      anime_id: target.id,
      manga_id: nil,
      character_id: 145_176,
      person_id: nil,
      role: 'Supporting'
    )
    expect(person_roles[2]).to have_attributes(
      anime_id: target.id,
      manga_id: nil,
      character_id: nil,
      person_id: 33_365,
      role: 'Director'
    )
    expect(person_roles[3]).to have_attributes(
      anime_id: target.id,
      manga_id: nil,
      character_id: nil,
      person_id: 30_337,
      role: 'Sound Director'
    )
  end
end
