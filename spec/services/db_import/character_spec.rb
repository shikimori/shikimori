describe DbImport::Character do
  let(:service) { DbImport::Character.new data }
  let(:data) do
    {
      id: id,
      name: 'Hitagi Senjougahara',
      image: image,
      japanese: '戦場ヶ原 ひたぎ',
      fullname: 'Hitagi "Tsundere-chan, Gahara-san, Senshougahara-san" Senjougahara',
      seyu: seyu,
      synopsis: synopsis
    }
  end
  let(:id) { 22_037 }
  let(:image) { nil }
  let(:seyu) { [] }
  let(:synopsis) { '' }

  subject(:entry) { service.call }

  it do
    expect(entry).to be_persisted
    expect(entry).to be_kind_of Character
    expect(entry).to have_attributes data.except(:synopsis, :image, :seyu)
  end

  describe '#assign_synopsis' do
    let(:synopsis) { '<b>test</b>' }
    let(:synopsis_with_source) do
      "[b]test[/b][source]http://myanimelist.net/character/#{id}[/source]"
    end

    it { expect(entry.description_en).to eq synopsis_with_source }
  end

  describe '#assign_image' do
    let(:image) { 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/PNG_transparency_demonstration_1.png/240px-PNG_transparency_demonstration_1.png' }

    describe 'import', :vcr do
      it { expect(entry.image).to be_present }
    end

    describe 'method call' do
      before { allow(DbImport::MalImage).to receive :call }
      it do
        expect(DbImport::MalImage)
          .to have_received(:call)
          .with entry, image
      end
    end
  end

  describe '#assign_seyu', :focus do
    let(:seyu) { [{ id: 61, type: :person, roles: %w[Japanese] }] }

    let!(:anime_role) { create :person_role, anime_id: 9999, character_id: id }
    let!(:person_role) { create :person_role, person_id: 9999, character_id: id }
    let(:person_roles) { entry.person_roles.order :id }

    describe 'import' do
      it do
        expect(person_roles).to have(2).items
        expect(person_roles.first).to eq anime_role
        expect(person_roles.last).to have_attributes(
          anime_id: nil,
          manga_id: nil,
          character_id: entry.id,
          person_id: 61,
          roles: %w[Japanese]
        )
      end
    end

    describe 'method call' do
      before { allow(DbImport::PersonRoles).to receive :call }
      it do
        expect(DbImport::PersonRoles)
          .to have_received(:call)
          .with entry, [], seyu
      end
    end

    describe 'clear people roles' do
      let(:seyu) { [] }
      before { subject }

      it do
        expect(person_roles).to eq [anime_role]
        expect { person_role.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
