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

  describe '#assign_seyu' do
    let(:seyu) { [{ id: 61, type: :person, role: 'Japanese' }] }

    describe 'import' do
      let(:person_roles) { entry.person_roles.order :id }
      it do
        expect(person_roles).to have(1).item
        expect(person_roles.first).to have_attributes(
          anime_id: nil,
          manga_id: nil,
          character_id: entry.id,
          person_id: 61,
          role: 'Japanese'
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

    describe 'does not clear' do
      let!(:person_role) do
        create :person_role,
          character_id: entry.id,
          person_id: 51,
          role: 'Test'
      end
      let(:seyu) { [] }
      before { subject }

      it { expect(person_role.reload).to be_persisted }
    end
  end
end
