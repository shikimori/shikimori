describe NameMatches::Namer do
  let(:service) { NameMatches::Namer.instance }

  let(:entry) do
    build :anime,
      id: id,
      kind: kind,
      name: 'Ootnik z Ootnik!',
      russian: russian,
      aired_on: aired_on,
      synonyms: [
        'Hunter x Hunter',
        'Hunters'
      ],
      english: [
        'English Hunter'
      ],
      japanese: [
        'ハンターxハンター'
      ]
  end

  let(:id) { 99999999999 }
  let(:kind) { :tv }
  let(:russian) { 'Охотник!' }
  let(:aired_on) { Date.parse '2000-01-01' }

  describe '#predefined' do
    context 'matched' do
      let(:id) { 136 }
      it { expect(service.predefined entry).to eq ['охотникхохотник'] }
    end

    context 'matched' do
      let(:id) { 9999999 }
      it { expect(service.predefined entry).to eq [] }
    end
  end

  describe '#name' do
    context 'with aired_on' do
      let(:aired_on) { Date.parse '2005-01-01' }
      it do
        expect(service.name entry).to eq [
          'ootnikzootnik!', 'ootnikzootnik!tv', 'ootnikzootnik!2005'
        ]
      end
    end

    context 'wo aired_on' do
      let(:aired_on) { nil }
      it do
        expect(service.name entry).to eq [
          'ootnikzootnik!', 'ootnikzootnik!tv'
        ]
      end
    end
  end

  describe '#alt' do
    it do
      expect(service.alt entry).to eq [
        'hunterxhuntertv', 'hunterxhunter2000',
        'hunterstv', 'hunters2000',
        'englishuntertv', 'englishunter2000',
        'ハンターxハンターtv', 'ハンターxハンター2000'
      ]
    end
  end

  describe '#alt2' do
    it do
      expect(service.alt2 entry).to eq [
        'hunterxhunter', 'hunters', 'englishunter', 'ハンターxハンター'
      ]
    end
  end

  describe '#alt3' do
    it do
      expect(service.alt3 entry).to eq [
        'ootnikzootnik', 'ootnikzootniktv', 'ootnikzootnik2000'
      ]
    end
  end

  describe '#russian' do
    context 'with russian' do
      let(:russian) { 'Охотник!' }
      it do
        expect(service.russian entry).to eq [
          'охотник!', 'охотник!tv', 'охотник!2000'
        ]
      end
    end

    context 'wo russian' do
      let(:russian) { nil }
      it { expect(service.russian entry).to eq [] }
    end
  end

  describe '#russian_alt' do
    it do
      expect(service.russian_alt entry).to eq  [
        'охотник', 'охотникtv', 'охотник2000'
      ]
    end
  end
end
