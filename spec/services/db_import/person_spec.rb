describe DbImport::Person do
  let(:service) { DbImport::Person.new data }
  let(:data) do
    {
      id: id,
      name: 'Anja Stadlober',
      image: image,
      japanese: '戦場ヶ原 ひたぎ',
      website: 'http://lenta.ru',
      birthday: Date.parse('Wed, 04 Apr 1984'),
      date_of_death: Date.parse('Wed, 04 Apr 1984')
    }
  end
  let(:id) { 22_037 }
  let(:image) { nil }

  subject(:entry) { service.call }

  it do
    expect(entry).to be_persisted
    expect(entry).to be_kind_of Person
    expect(entry).to have_attributes data.except(:image)
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
          .with entry: entry, image_url: image
      end
    end
  end
end
