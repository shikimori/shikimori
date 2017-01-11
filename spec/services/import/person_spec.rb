describe Import::Person do
  let(:service) { Import::Person.new data }
  let(:data) do
    {
      id: id,
      name: 'Anja Stadlober',
      image: image,
      japanese: '戦場ヶ原 ひたぎ',
      website: 'http://lenta.ru'
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
      before { allow(Import::MalImage).to receive :call }
      it do
        expect(Import::MalImage)
          .to have_received(:call)
          .with entry, image
      end
    end
  end
end
